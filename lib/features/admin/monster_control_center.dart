import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class MonsterControlCenter extends StatefulWidget {
  const MonsterControlCenter({super.key});

  @override
  State<MonsterControlCenter> createState() => _MonsterControlCenterState();
}

class _MonsterControlCenterState extends State<MonsterControlCenter> {
  final AdminService _adminService = AdminService();
  bool _showLibrary = false;
  Map<String, dynamic>? _selectedMonster; // For detail popup
  List<Map<String, dynamic>> _legendaries = [];
  bool _isLoadingLibrary = false;

  Future<void> _toggleLibrary() async {
    if (!_showLibrary) {
      setState(() {
        _showLibrary = true;
        _isLoadingLibrary = true;
      });
      final data = await _adminService.fetchLegendaryPokemon();
      if (mounted) {
        setState(() {
          _legendaries = data;
          _isLoadingLibrary = false;
        });
      }
    } else {
      setState(() {
        _showLibrary = false;
        _selectedMonster = null;
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: MascotCard(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Monster Control\nCenter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: Color(0xFF2C3E1F),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildControlButton(context, 'ADD MONSTER', onTap: () => context.push('/admin-map')),
                    const SizedBox(height: 14),
                    _buildControlButton(context, 'DELETE MONSTER', onTap: () => context.push('/admin-monster-list')),
                    const SizedBox(height: 14),
                    _buildControlButton(context, 'EDIT MONSTER', onTap: () => context.push('/admin-edit-selection')),
                    const SizedBox(height: 14),
                    _buildControlButton(context, 'LIST OF MONSTERS', onTap: _toggleLibrary),
                  ],
                ),
              ),
            ),
          ),

          if (_showLibrary) _buildLibraryOverlay(),
          if (_selectedMonster != null) _buildDetailOverlay(),
        ],
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  Widget _buildLibraryOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: MascotCard(
            height: double.infinity,
            showShadow: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LEGENDARY LIST',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF2C3E1F)),
                      onPressed: () => setState(() => _showLibrary = false),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoadingLibrary
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E1F)))
                      : _legendaries.isEmpty
                          ? const Center(child: Text('NO MONSTERS FOUND\nCHECK INTERNET', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F))))
                          : ListView.separated(
                              itemCount: _legendaries.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final p = _legendaries[index];
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedMonster = p),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: const Color(0xFF2C3E1F), width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: Image.network(
                                            p['sprite_url'] ?? '', 
                                            filterQuality: FilterQuality.none,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(p['name'] ?? 'UNKNOWN', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2C3E1F))),
                                              Text('TYPE: ${p['type'] ?? 'UNKNOWN'}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF2C3E1F))),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF2C3E1F)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showLibrary = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA50000),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('GO BACK', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailOverlay() {
    final p = _selectedMonster!;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MascotCard(
              showShadow: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p['name'] ?? 'UNKNOWN',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F)),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2C3E1F), width: 3),
                      ),
                      child: Image.network(p['sprite_url'] ?? '', fit: BoxFit.contain, filterQuality: FilterQuality.none),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('TYPE:', p['type'] ?? 'UNKNOWN'),
                    _buildDetailRow('HEIGHT:', '${p['height']}m'),
                    _buildDetailRow('WEIGHT:', '${p['weight']}kg'),
                    _buildDetailRow('ABILITIES:', p['abilities'] ?? 'NONE'),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _selectedMonster = null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA50000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('GO BACK', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E1F))),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFA50000))),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, String title, {required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA50000),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.black, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
