import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

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

class PokemonService {
  Future<List<PokemonModel>> fetchMyPokemon() async {
    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=9&offset=0'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        
        final futures = results.map((result) => _fetchDetails(result['url'])).toList();
        final pokemons = await Future.wait(futures);
        return pokemons.whereType<PokemonModel>().toList();
      }
    } catch (e) {
      print('Error fetching pokemon: $e');
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
