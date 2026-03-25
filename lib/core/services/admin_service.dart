import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin Service for managing spawned monsters
class AdminService with ChangeNotifier {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Toggle admin mode (stored locally)
  Future<void> toggleAdmin(bool value) async {
    _isAdmin = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_admin', value);
    notifyListeners();
  }

  /// Load admin state from local storage
  Future<void> loadAdminState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdmin = prefs.getBool('is_admin') ?? false;
    notifyListeners();
  }

  /// Save a spawned monster to Supabase
  Future<bool> spawnMonster({
    required int pokemonId,
    required String name,
    required String type,
    required String spriteUrl,
    required double lat,
    required double lng,
    required double radius,
  }) async {
    try {
      final client = _supabase;
      if (client != null) {
        final data = {
          'pokemon_id': pokemonId,
          'name': name,
          'type': type,
          'sprite_url': spriteUrl,
          'latitude': lat,
          'longitude': lng,
          'radius': radius,
          'spawned_by': client.auth.currentUser?.id,
        };
        debugPrint('SPAWNING MONSTER IN SUPABASE: $data');
        await client.from('spawned_monsters').insert(data);
        return true;
      } else {
        debugPrint('SUPABASE CLIENT IS NULL');
      }
    } catch (e) {
      debugPrint('Error spawning monster: $e');
    }
    return false;
  }

  /// Get all spawned monsters
  Future<List<Map<String, dynamic>>> getSpawnedMonsters() async {
    try {
      final client = _supabase;
      if (client != null) {
        final data = await client
            .from('spawned_monsters')
            .select()
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      debugPrint('Error fetching spawned monsters: $e');
    }
    return [];
  }

  /// Delete multiple spawned monsters
  Future<bool> deleteSpawnedMonsters(List<int> ids) async {
    try {
      final client = _supabase;
      if (client != null && ids.isNotEmpty) {
        await client.from('spawned_monsters').delete().inFilter('id', ids);
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting monsters: $e');
    }
    return false;
  }

  /// Update a spawned monster
  Future<bool> updateSpawnedMonster({
    required int id,
    String? name,
    String? type,
    String? spriteUrl,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    try {
      final client = _supabase;
      if (client != null) {
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (type != null) updates['type'] = type;
        if (spriteUrl != null) updates['sprite_url'] = spriteUrl;
        if (lat != null) updates['latitude'] = lat;
        if (lng != null) updates['longitude'] = lng;
        if (radius != null) updates['radius'] = radius;

        if (updates.isNotEmpty) {
          await client.from('spawned_monsters').update(updates).eq('id', id);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error updating monster: $e');
    }
    return false;
  }

  /// Fetch Pokemon list from PokeAPI for dropdown
  Future<List<Map<String, dynamic>>> fetchPokemonList({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=0'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((r) => {
          'name': r['name'].toString().toUpperCase(),
          'url': r['url'],
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching pokemon list: $e');
    }
    return [];
  }

  /// Fetch Pokemon details from PokeAPI
  Future<Map<String, dynamic>?> fetchPokemonDetails(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final id = data['id'];
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

        return {
          'id': id,
          'name': name,
          'type': type,
          'sprite_url': spriteUrl,
          'weight': data['weight'] / 10.0, // convert to kg
          'height': data['height'] / 10.0, // convert to m
          'abilities': (data['abilities'] as List).map((a) => a['ability']['name']).join(', ').toUpperCase(),
        };
      }
    } catch (e) {
      debugPrint('Error fetching pokemon details: $e');
    }
    return null;
  }
  /// Fetch a list of legendary Pokemon for the library screen
  Future<List<Map<String, dynamic>>> fetchLegendaryPokemon() async {
    final legendaryNames = [
      'mewtwo', 'lugia', 'ho-oh', 'rayquaza', 'kyogre', 'groudon',
      'dialga', 'palkia', 'giratina-altered', 'arceus', 'reshiram', 'zekrom',
      'kyurem', 'xerneas', 'yveltal', 'zygarde-50', 'solgaleo', 'lunala',
      'necrozma', 'zacian', 'zamazenta', 'eternatus'
    ];

    try {
      final futures = legendaryNames.map((name) => fetchPokemonDetails('https://pokeapi.co/api/v2/pokemon/$name'));
      final results = await Future.wait(futures);
      return results.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching legendary list: $e');
      return [];
    }
  }

  /// Get app configuration (simulated EC2/VPN)
  Future<Map<String, bool>> getAppConfig() async {
    try {
      final client = _supabase;
      if (client != null) {
        final data = await client.from('app_config').select();
        final Map<String, bool> config = {};
        for (var item in data) {
          config[item['key']] = item['value'];
        }
        return config;
      }
    } catch (e) {
      debugPrint('Error fetching app config: $e');
    }
    return {'ec2_server': true, 'vpn_connection': true};
  }

  /// Update app configuration
  Future<bool> updateAppConfig(String key, bool value) async {
    try {
      final client = _supabase;
      if (client != null) {
        await client.from('app_config').update({'value': value}).eq('key', key);
        return true;
      }
    } catch (e) {
      debugPrint('Error updating app config: $e');
    }
    return false;
  }
}
