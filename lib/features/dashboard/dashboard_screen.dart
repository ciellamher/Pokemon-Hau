import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/breathing_widget.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class DashboardScreen extends StatefulWidget {
  final bool showControl;
  const DashboardScreen({super.key, this.showControl = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PokemonService _pokemonService = PokemonService();
  final AdminService _adminService = AdminService();
  List<PokemonModel> _pokemons = [];
  bool _isLoading = true;
  String _playerName = 'TRAINER';
  int _level = 1;
  int _monstersCaught = 0;
  bool _isAdmin = false;
  late bool _showAppControl;
  Map<String, bool> _appConfig = {'ec2_server': true, 'vpn_connection': true};

  @override
  void initState() {
    super.initState();
    _showAppControl = widget.showControl;
    _pokemonService.addListener(_updatePokemons);
    _adminService.addListener(_handleAdminChange);
    _loadSprites();
    _loadProfile();
    _checkAdminStatus();
    _fetchAppConfig();
  }

  @override
  void dispose() {
    _pokemonService.removeListener(_updatePokemons);
    _adminService.removeListener(_handleAdminChange);
    super.dispose();
  }

  void _handleAdminChange() {
    if (mounted) {
      setState(() => _isAdmin = _adminService.isAdmin);
    }
  }

  Future<void> _checkAdminStatus() async {
    await _adminService.loadAdminState();
    if (mounted) {
      setState(() => _isAdmin = _adminService.isAdmin);
    }
  }

  Future<void> _fetchAppConfig() async {
    final config = await _adminService.getAppConfig();
    if (mounted) {
      setState(() => _appConfig = config);
    }
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
        child: Stack(
          children: [
            Column(
              children: [
                // Top Player Card / Admin Card
                _isAdmin ? _buildAdminProfileBar() : _buildPlayerProfileBar(),

                // Main "MY POKEMON" Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MascotCard(
                      height: double.infinity,
                      title: _isAdmin ? 'MANAGE MONSTERS' : 'MY POKEMON',
                      titleFontSize: 22,
                      child: Column(
                        children: [
                          // Grass grid area — fills all remaining space
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
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
                                  : _pokemons.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'NO POKEMON YET!\nGO CATCH SOME!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: Colors.white,
                                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        padding: const EdgeInsets.all(10),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
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
                          ),
                          
                          const SizedBox(height: 10),
                          // Manage button
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isAdmin) {
                                  context.push('/monster-control');
                                } else {
                                  context.push('/library', extra: _pokemons);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA50000),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: Text(_isAdmin ? 'MANAGE' : 'LIST', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showAppControl) _buildAppControlOverlay(),
          ],
        ),
      ),
      
      // Custom overlapping bottom navigation bar
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  Widget _buildPlayerProfileBar() {
    return Padding(
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
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
              child: ClipOval(child: Image.asset('Assets/Images/usericon.png', fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.person))),
            ),
            const SizedBox(width: 16),
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
            ElevatedButton(
              onPressed: () => context.push('/settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA50000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black, width: 2)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(80, 36),
              ),
              child: const Text('SETTINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProfileBar() {
    return Padding(
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
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
              child: ClipOval(child: Image.asset('Assets/Images/usericon.png', fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.person))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('ADMIN NAME: $_playerName', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2C3E1F))),
                   const Text('ROLE: SUPER ADMIN', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFFA50000))),
                   const SizedBox(height: 4),
                   GestureDetector(
                     onTap: () => setState(() => _showAppControl = true),
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(color: const Color(0xFFA50000), borderRadius: BorderRadius.circular(8)),
                       child: const Text('APP CONTROLLED CENTER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                     ),
                   ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.push('/settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA50000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black, width: 2)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(80, 36),
              ),
              child: const Text('SETTINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppControlOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: MascotCard(
              title: 'APP CONTROL\nCENTER',
              titleFontSize: 28,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showAppControl = false)),
                      ],
                    ),
                    _buildControlItem('EC2 WEB\nSERVER', 'ec2_server'),
                    const SizedBox(height: 16),
                    _buildControlItem('VPN\nCONNECTION', 'vpn_connection'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlItem(String title, String configKey) {
    bool isOn = _appConfig[configKey] ?? true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C3E1F), width: 3),
      ),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF2C3E1F))),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              bool newValue = !isOn;
              setState(() => _appConfig[configKey] = newValue);
              await _adminService.updateAppConfig(configKey, newValue);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isOn ? const Color(0xFF67B569) : const Color(0xFFA50000),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(isOn ? 'ON' : 'OFF', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
