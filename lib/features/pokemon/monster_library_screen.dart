import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';

import 'pokemon_service.dart';

class MonsterLibraryScreen extends StatefulWidget {
  const MonsterLibraryScreen({super.key});

  @override
  State<MonsterLibraryScreen> createState() => _MonsterLibraryScreenState();
}

class _MonsterLibraryScreenState extends State<MonsterLibraryScreen> {
  final PokemonService _pokemonService = PokemonService();
  List<PokemonModel> _pokemons = [];

  @override
  void initState() {
    super.initState();
    _pokemons = _pokemonService.caughtPokemons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                onPressed: () => context.pop(),
              ),
            ),
            
            // Main Library Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCF3D7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2C3E1F), width: 5),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Title
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'MONSTER\nLIBRARY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              letterSpacing: 1.5,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 4
                                ..color = const Color(0xFF2C3E1F),
                            ),
                          ),
                          const Text(
                            'MONSTER\nLIBRARY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // List of monsters
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _pokemons.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final monster = _pokemons[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDFDF5), // Very light beige almost white
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image and ID
                                  SizedBox(
                                    width: 80,
                                    child: Column(
                                      children: [
                                        Image.network(
                                          monster.spriteUrl,
                                          height: 70,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.none,
                                          errorBuilder: (c, e, s) => const SizedBox(height: 70, child: Icon(Icons.pets)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          monster.id,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                            color: Color(0xFF4A3E2A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Data
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('MONSTER NAME: ${monster.name}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4A3E2A))),
                                        const SizedBox(height: 2),
                                        Text('TYPE: ${monster.type}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4A3E2A))),
                                        const SizedBox(height: 2),
                                        const Text('SPAWN LOCATION:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4A3E2A))),
                                        const SizedBox(height: 2),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('LATITUDE: ${monster.lat.toStringAsFixed(7)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4A3E2A))),
                                              const SizedBox(height: 2),
                                              Text('LONGITUDE: ${monster.lng.toStringAsFixed(7)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4A3E2A))),
                                              const SizedBox(height: 2),
                                              Text('RADIUS: ${monster.radius.toStringAsFixed(2)}m', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF4A3E2A))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Explicitly sizing empty space where the navbar will overlap if we don't rely only on extendBody.
            // Since bottomNavigationBar handles the Safe overlap, we just add a small spacer to avoid items hiding behind the navbar inside the list.
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
