import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';
import 'package:torch_light/torch_light.dart';
import 'package:confetti/confetti.dart';
import 'package:pokemon_hau/core/services/audio_service.dart';
import 'package:pokemon_hau/features/pokemon/catch_monster.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _initialPosition = const LatLng(15.1332210, 120.5910000); 
  final PokemonService _pokemonService = PokemonService();
  List<PokemonModel> _wildPokemons = [];
  bool _isLoading = true;
  int _detectAgainCount = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadWildPokemon();
    AudioService().playHuntingMusic();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    AudioService().resumeMainTheme();
    super.dispose();
  }

  Future<void> _loadWildPokemon() async {
    setState(() => _isLoading = true);
    
    // Fetch both wild and admin-placed monsters
    final wild = await _pokemonService.fetchWildPokemon();
    final spawned = await _pokemonService.fetchSpawnedMonsters();

    if (mounted) {
      setState(() {
        _wildPokemons = [...wild, ...spawned];
        _isLoading = false;
      });
    }
  }

  void _handleDetectAgain() async {
    _detectAgainCount++;
    if (_detectAgainCount % 6 == 0) {
      _showNoMonsterDialog();
    } else {
      _loadWildPokemon();
    }
  }

  void _showNoMonsterDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF3D7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF2C3E1F), width: 6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'NO MONSTERS\nDETECTED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C3E1F),
                ),
              ),
               const SizedBox(height: 10),
               Image.asset(
                 'Assets/Images/sadbear.png', // Assuming this is the sad mascot from the screenshot
                 height: 120,
                 fit: BoxFit.contain,
               ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          side: const BorderSide(color: Colors.black12, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        ),
                        child: const Text(
                          'GO BACK',
                          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _loadWildPokemon();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A0000), // Darker red to match the screenshot better
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        ),
                        child: const Text(
                          'DETECT AGAIN',
                          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _flashTorch() async {
    try {
      if (await TorchLight.isTorchAvailable()) {
        for (int i = 0; i < 5; i++) {
          await TorchLight.enableTorch();
          await Future.delayed(const Duration(milliseconds: 100));
          await TorchLight.disableTorch();
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      debugPrint('Error flashing torch: $e');
    }
  }

  void _onPokemonTap(PokemonModel pokemon) async {
    // Remove from map immediately so it doesn't show as re-catchable
    setState(() => _wildPokemons.removeWhere((p) => p.name == pokemon.name));

    // Catch it (saves to caught_pokemon, removes from spawned_monsters if applicable)
    await _pokemonService.catchPokemon(pokemon);
    
    // Play SFX and confetti, and pause the background hunting music
    AudioService().pauseBackgroundMusic();
    AudioService().playCaptureSfx();
    _confettiController.play();
    
    // Flash the device torch 5 times
    _flashTorch();
    
    if (mounted) {
      // Show the Congratulations Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => CatchMonsterDialog(
          pokemon: pokemon,
          onBack: () {
            Navigator.pop(ctx);
            context.pop(); // Leave map
          },
          onDetectAgain: () {
            Navigator.pop(ctx);
            AudioService().playHuntingMusic(); // Resume hunting music
            _loadWildPokemon(); // Refresh wild ones
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: MascotCard(
            height: double.infinity,
            hasBackButton: true,
            onBackPressed: () => context.pop(),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Map View
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26, width: 2),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: _initialPosition,
                            initialZoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.pokemon_hau',
                            ),
                            CircleLayer(
                              circles: _wildPokemons.where((p) => p.radius > 50).map((p) => CircleMarker(
                                point: LatLng(p.lat, p.lng),
                                radius: p.radius,
                                useRadiusInMeter: true,
                                color: const Color(0xFFA50000).withValues(alpha: 0.1),
                                borderColor: const Color(0xFFA50000),
                                borderStrokeWidth: 1,
                              )).toList(),
                            ),
                            if (!_isLoading)
                              MarkerLayer(
                                markers: _wildPokemons.map((pokemon) {
                                  return Marker(
                                    point: LatLng(pokemon.lat, pokemon.lng),
                                    width: 60,
                                    height: 60,
                                    child: GestureDetector(
                                      onTap: () => _onPokemonTap(pokemon),
                                      child: Image.network(
                                        pokemon.spriteUrl,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.none,
                                        errorBuilder: (c, e, s) => const Icon(Icons.catching_pokemon, color: Colors.red),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                      
                      // Red coordinates box and Detect Button
                      Positioned(
                        bottom: 10,
                        left: 20,
                        right: 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA50000), // Dark Red
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'LAT: ${_initialPosition.latitude.toStringAsFixed(7)} LONG: ${_initialPosition.longitude.toStringAsFixed(7)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'RADIUS: 100.00m',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleDetectAgain,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA50000),
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.black, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: const Text('DETECT AGAIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Confetti overlay
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          colors: const [Colors.red, Colors.yellow, Colors.blue, Colors.green],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
