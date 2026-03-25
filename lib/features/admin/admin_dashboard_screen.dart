import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/breathing_widget.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final PokemonService _pokemonService = PokemonService();
  List<PokemonModel> _pokemons = [];
  bool _isLoading = true;
  String _adminName = 'ADMIN';
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
    if (mounted) {
      setState(() {
        _pokemons = pokemons;
        _monstersCaught = pokemons.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    final profile = await _pokemonService.fetchUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _adminName = (profile['player_name'] ?? 'ADMIN').toString().toUpperCase();
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
            // Top Admin Card
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
                    // Admin Icon
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
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.admin_panel_settings),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ADMIN NAME: $_adminName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('MONSTERS CAUGHT: $_monstersCaught', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const Text('RANK: 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
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

            // Main "MONSTERS" Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MascotCard(
                  height: double.infinity,
                  title: 'MONSTERS',
                  titleFontSize: 28,
                  child: Column(
                    children: [
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
                                    child: Image.network(
                                      _pokemons[index].spriteUrl,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                      errorBuilder: (ctx, err, stack) => const Icon(Icons.catching_pokemon, color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // Manage Monsters button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () => context.push('/monster-control'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA50000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('MANAGE MONSTERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
