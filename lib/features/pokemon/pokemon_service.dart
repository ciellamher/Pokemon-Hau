import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PokemonModel {
  final String id;
  final String name;
  final String type;
  final String spriteUrl;
  final double lat;
  final double lng;
  final double radius;
  final int? dbId; // Store Supabase ID for spawned monsters

  PokemonModel({
    required this.id,
    required this.name,
    required this.type,
    required this.spriteUrl,
    required this.lat,
    required this.lng,
    required this.radius,
    this.dbId,
  });
}

class PokemonService with ChangeNotifier {
  static final PokemonService _instance = PokemonService._internal();
  factory PokemonService() => _instance;
  PokemonService._internal();

  final List<PokemonModel> _caughtPokemons = [];
  List<PokemonModel> get caughtPokemons => _caughtPokemons;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => _supabase?.auth.currentUser?.id;

  /// Load caught pokemon from Supabase (or fallback to local)
  Future<void> loadCaughtPokemon() async {
    try {
      final client = _supabase;
      final uid = _userId;

      if (client != null && uid != null) {
        // Fetch from Supabase
        final data = await client
            .from('caught_pokemon')
            .select()
            .eq('user_id', uid)
            .order('caught_at', ascending: false);

        _caughtPokemons.clear();
        for (var item in data) {
          _caughtPokemons.add(PokemonModel(
            id: item['pokemon_id'].toString().padLeft(3, '0'),
            name: item['name'],
            type: 'UNKNOWN',
            spriteUrl: item['sprite_url'],
            lat: 0,
            lng: 0,
            radius: 0,
          ));
        }
        notifyListeners();
        return;
      }

      // Fallback to local
      await _loadFromLocal();
    } catch (e) {
      debugPrint('Error loading caught pokemon: $e');
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? caughtJson = prefs.getString('caught_pokemons');
      if (caughtJson != null) {
        final List decoded = json.decode(caughtJson);
        _caughtPokemons.clear();
        for (var item in decoded) {
          _caughtPokemons.add(PokemonModel(
            id: item['id'],
            name: item['name'],
            type: item['type'],
            spriteUrl: item['spriteUrl'],
            lat: item['lat'],
            lng: item['lng'],
            radius: item['radius'],
          ));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading local data: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List encoded = _caughtPokemons.map((p) => {
        'id': p.id,
        'name': p.name,
        'type': p.type,
        'spriteUrl': p.spriteUrl,
        'lat': p.lat,
        'lng': p.lng,
        'radius': p.radius,
      }).toList();
      await prefs.setString('caught_pokemons', json.encode(encoded));
    } catch (e) {
      debugPrint('Error saving local data: $e');
    }
  }

  /// Catch a pokemon and save to Supabase + local
  Future<void> catchPokemon(PokemonModel pokemon) async {
    if (!_caughtPokemons.any((p) => p.name == pokemon.name)) {
      _caughtPokemons.add(pokemon);
      _saveToLocal();
      notifyListeners();

      // Save to Supabase
      try {
        final client = _supabase;
        final uid = _userId;

        if (client != null && uid != null) {
          await client.from('caught_pokemon').insert({
            'user_id': uid,
            'pokemon_id': int.tryParse(pokemon.id) ?? 0,
            'name': pokemon.name,
            'sprite_url': pokemon.spriteUrl,
          });

          // Update monster_caught_count in profiles
          await client
              .from('profiles')
              .update({'monster_caught_count': _caughtPokemons.length})
              .eq('id', uid);

          // If it was a spawned monster, remove it from the shared world
          if (pokemon.dbId != null) {
            await client.from('spawned_monsters').delete().eq('id', pokemon.dbId!);
            debugPrint('REMOVED SPAWNED MONSTER FROM DB: ${pokemon.dbId}');
          }
        }
      } catch (e) {
        debugPrint('Error saving to Supabase: $e');
      }
    }
  }

  Future<List<PokemonModel>> fetchMyPokemon() async {
    if (_caughtPokemons.isEmpty) {
      await loadCaughtPokemon();
    }
    return _caughtPokemons;
  }

  Future<List<PokemonModel>> fetchWildPokemon() async {
    try {
      final randomOffset = Random().nextInt(150);
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=5&offset=$randomOffset'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        
        final futures = results.map((result) => _fetchDetails(result['url'])).toList();
        final pokemons = await Future.wait(futures);
        return pokemons.whereType<PokemonModel>().toList();
      }
    } catch (e) {
      debugPrint('Error fetching wild pokemon: $e');
    }
    return [];
  }

  /// Fetch admin-placed monsters from Supabase
  Future<List<PokemonModel>> fetchSpawnedMonsters() async {
    try {
      final client = _supabase;
      if (client != null) {
        final data = await client.from('spawned_monsters').select();
        return (data as List).map((item) => PokemonModel(
          id: item['pokemon_id'].toString().padLeft(3, '0'),
          name: item['name'],
          type: item['type'],
          spriteUrl: item['sprite_url'],
          lat: (item['latitude'] as num).toDouble(),
          lng: (item['longitude'] as num).toDouble(),
          radius: (item['radius'] as num).toDouble(),
          dbId: item['id'] as int,
        )).toList();
      }
    } catch (e) {
      debugPrint('Error fetching spawned monsters: $e');
    }
    return [];
  }

  Future<PokemonModel?> _fetchDetails(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final id = data['id'].toString().padLeft(3, '0');
        final name = data['name'].toString().toUpperCase();
        
        String type = 'UNKNOWN';
        if (data['types'] != null && data['types'].isNotEmpty) {
          type = data['types'][0]['type']['name'].toString().toUpperCase();
        }

        String spriteUrl = '';
        try {
          spriteUrl = data['sprites']['versions']['generation-v']['black-white']['animated']['front_default'] ?? 
                      data['sprites']['front_default'];
        } catch (_) {
          spriteUrl = data['sprites']['front_default'] ?? '';
        }

        final random = Random();
        final lat = 15.1332210 + (random.nextDouble() - 0.5) * 0.01;
        final lng = 120.5910000 + (random.nextDouble() - 0.5) * 0.01;

        return PokemonModel(
          id: id,
          name: name,
          type: type,
          spriteUrl: spriteUrl,
          lat: lat,
          lng: lng,
          radius: 50.00,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Fetch rankings from Supabase profiles table
  Future<List<Map<String, dynamic>>> fetchRankings() async {
    try {
      final client = _supabase;
      if (client != null) {
        final data = await client
            .from('profiles')
            .select('player_name, monster_caught_count')
            .order('monster_caught_count', ascending: false)
            .limit(50);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      debugPrint('Error fetching rankings: $e');
    }
    return [];
  }

  /// Fetch current user's profile from Supabase
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final client = _supabase;
      final uid = _userId;
      if (client != null && uid != null) {
        final data = await client
            .from('profiles')
            .select()
            .eq('id', uid)
            .single();
        return data;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
    return null;
  }

  /// Update user profile
  Future<void> updateProfile({String? playerName, String? username}) async {
    try {
      final client = _supabase;
      final uid = _userId;
      if (client != null && uid != null) {
        final updates = <String, dynamic>{};
        if (playerName != null) updates['player_name'] = playerName;
        if (username != null) updates['username'] = username;
        if (updates.isNotEmpty) {
          await client.from('profiles').update(updates).eq('id', uid);
        }
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  /// Sign out and clear local data
  Future<void> signOut() async {
    try {
      await _supabase?.auth.signOut();
      _caughtPokemons.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final client = _supabase;
      final uid = _userId;
      if (client != null && uid != null) {
        // Delete caught pokemon
        await client.from('caught_pokemon').delete().eq('user_id', uid);
        // Delete profile
        await client.from('profiles').delete().eq('id', uid);
        // Sign out
        await signOut();
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
    }
  }
}
