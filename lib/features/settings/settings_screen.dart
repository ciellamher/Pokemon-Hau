import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/stroke_text.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PokemonService _pokemonService = PokemonService();
  final AdminService _adminService = AdminService();
  String _username = 'LOADING...';
  String _playerName = 'LOADING...';
  int _level = 1;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _checkAdminStatus();
  }

  Future<void> _loadProfile() async {
    final profile = await _pokemonService.fetchUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _username = (profile['username'] ?? 'UNKNOWN').toString().toUpperCase();
        _playerName = (profile['player_name'] ?? 'UNKNOWN').toString().toUpperCase();
        _level = profile['level'] ?? 1;
      });
    }
  }

  Future<void> _checkAdminStatus() async {
    await _adminService.loadAdminState();
    if (mounted) {
      setState(() => _isAdmin = _adminService.isAdmin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: MascotCard(
                hasBackButton: true,
                onBackPressed: () => context.pop(),
                title: 'SETTINGS',
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Monster Avatar (Circular)
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF2C3E1F), width: 4),
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Image.network(
                              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/58.png', // Example Growlithe as in screenshot style
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => const Icon(Icons.pets, size: 80),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // User Info Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('USERNAME: $_username', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F))),
                            const SizedBox(height: 4),
                            Text('ADMIN NAME: $_playerName', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F))),
                            const SizedBox(height: 4),
                            Text('LEVEL: $_level', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      _buildActionButton('EDIT PROFILE', onTap: () => context.push('/edit-profile')),
                      const SizedBox(height: 12),
                      
                      if (_isAdmin) ...[
                        _buildActionButton('APP CONTROL CENTER', onTap: () => context.push('/dashboard', extra: {'show_control': true})),
                        const SizedBox(height: 12),
                        _buildActionButton('LEAVE ADMIN', onTap: () async {
                          await _adminService.toggleAdmin(false);
                          if (mounted) context.go('/dashboard');
                        }),
                        const SizedBox(height: 12),
                      ] else ...[
                        _buildActionButton('ADMIN MODE', onTap: () async {
                          await _adminService.toggleAdmin(true);
                          if (mounted) context.go('/dashboard');
                        }),
                        const SizedBox(height: 12),
                      ],
                      
                      _buildActionButton('ABOUT US', onTap: () => context.push('/about-us')),
                      const SizedBox(height: 12),
                      
                      _buildActionButton('DELETE ACCOUNT', onTap: () => _showDeleteDialog(context)),
                      const SizedBox(height: 12),
                      
                      _buildActionButton('SIGN OUT', onTap: () async {
                        await _pokemonService.signOut();
                        if (mounted) context.go('/signin');
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  Widget _buildActionButton(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF7A0000), // Dark Red
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF2C3E1F), width: 3),
        ),
        child: Center(
          child: StrokeText(
            text: title,
            fontSize: 18,
            letterSpacing: 1.0,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final deleteController = TextEditingController();
    showDialog(
      context: context,
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
              const StrokeText(text: 'RETIRE FROM THE\nEXPEDITION?', fontSize: 18, textColor: Color(0xFF2C3E1F), strokeColor: Colors.transparent),
              const SizedBox(height: 12),
              const Text(
                'Warning, Trainer! This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: deleteController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton('GOODBYE', onTap: () async {
                      if (deleteController.text.trim().toUpperCase() == 'DELETE') {
                        Navigator.pop(ctx);
                        await _pokemonService.deleteAccount();
                        if (mounted) context.go('/signin');
                      }
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.black)),
                        child: const Center(child: Text('STAY', style: TextStyle(fontWeight: FontWeight.w900))),
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
}
