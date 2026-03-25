import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PokemonModel {
  final String id;
  final String name;
  final String type;
  final String spriteUrl;
  final double lat;
  final double lng;
  final double radius;

  PokemonModel({
    required this.id,
    required this.name,
    required this.type,
    required this.spriteUrl,
    required this.lat,
    required this.lng,
    required this.radius,
  });
}

class PokemonService with ChangeNotifier {
  static final PokemonService _instance = PokemonService._internal();
  factory PokemonService() => _instance;
  PokemonService._internal();

  final List<PokemonModel> _caughtPokemons = [];
  List<PokemonModel> get caughtPokemons => _caughtPokemons;

  Future<void> loadCaughtPokemon() async {
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
      print('Error loading caught pokemon: $e');
    }
  }

  Future<void> saveCaughtPokemon() async {
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
      print('Error saving caught pokemon: $e');
    }
  }

  void catchPokemon(PokemonModel pokemon) {
    if (!_caughtPokemons.any((p) => p.name == pokemon.name)) {
      _caughtPokemons.add(pokemon);
      saveCaughtPokemon();
      notifyListeners();
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
      print('Error fetching wild pokemon: $e');
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
}
