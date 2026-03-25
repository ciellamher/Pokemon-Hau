import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/breathing_widget.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PokemonService _pokemonService = PokemonService();
  List<PokemonModel> _pokemons = [];
  bool _isLoading = true;
  String _playerName = 'TRAINER';
  int _level = 1;
  int _monstersCaught = 0;

  @override
  void initState() {
    super.initState();
    _pokemonService.addListener(_updatePokemons);
    _loadSprites();
    _loadProfile();
  }

  @override
  void dispose() {
    _pokemonService.removeListener(_updatePokemons);
    super.dispose();
  }

  void _updatePokemons() {
    if (mounted) {
      setState(() {
        _pokemons = _pokemonService.caughtPokemons;
        _monstersCaught = _pokemons.length;
      });
    }
  }

  Future<void> _loadSprites() async {
    final pokemons = await _pokemonService.fetchMyPokemon();
    setState(() {
      _pokemons = pokemons;
      _monstersCaught = pokemons.length;
      _isLoading = false;
    });
  }

  Future<void> _loadProfile() async {
    final profile = await _pokemonService.fetchUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _playerName = (profile['player_name'] ?? 'TRAINER').toString().toUpperCase();
        _level = profile['level'] ?? 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Player Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF3D7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2C3E1F), width: 5),
                ),
                child: Row(
                  children: [
                    // Profile Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: ClipOval(
                         child: Image.asset(
                          'Assets/Images/usericon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PLAYER NAME: $_playerName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('LEVEL: $_level', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('MONSTERS: $_monstersCaught', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    // Settings Button
                    ElevatedButton(
                      onPressed: () => context.push('/settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA50000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(80, 36),
                      ),
                      child: const Text('SETTINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            // Main "MY POKEMON" Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MascotCard(
                  height: double.infinity,
                  child: Column(
                    children: [
                      const Text(
                        'MY POKEMON',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Grass grid area
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black26, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('Assets/Images/grass.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _isLoading 
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: _pokemons.length,
                                itemBuilder: (context, index) {
                                  return BreathingWidget(
                                    child: GestureDetector(
                                      onTap: () => context.push('/library', extra: _pokemons),
                                      child: Image.network(
                                        _pokemons[index].spriteUrl,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.none,
                                        errorBuilder: (ctx, err, stack) => const Icon(Icons.catching_pokemon, color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // List button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () => context.push('/library', extra: _pokemons),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA50000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text('LIST', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom navbar
          ],
        ),
      ),
      
      // Custom overlapping bottom navigation bar
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
