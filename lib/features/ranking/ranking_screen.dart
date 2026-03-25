import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final PokemonService _pokemonService = PokemonService();
  List<Map<String, dynamic>> _rankings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    final data = await _pokemonService.fetchRankings();
    if (mounted) {
      setState(() {
        _rankings = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: MascotCard(
          height: double.infinity,
          child: Column(
            children: [
              const Text(
                'RANKINGS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFF2C3E1F),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E1F)))
                    : _rankings.isEmpty
                        ? const Center(
                            child: Text(
                              'No trainers found yet!\nBe the first to catch a monster.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2C3E1F),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _rankings.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = _rankings[index];
                              final rank = index + 1;
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF2C3E1F), width: 1.5),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'Assets/Images/usericon.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PLAYER NAME: ${user['player_name'] ?? 'UNKNOWN'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: Color(0xFF2C3E1F),
                                            ),
                                          ),
                                          Text(
                                            'MONSTERS CAUGHT: ${user['monster_caught_count'] ?? 0}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: Color(0xFF2C3E1F),
                                            ),
                                          ),
                                          Text(
                                            'RANK: $rank',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: Color(0xFF2C3E1F),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
