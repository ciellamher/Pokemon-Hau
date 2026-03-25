import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class AdminEditMonsterSelectionScreen extends StatefulWidget {
  const AdminEditMonsterSelectionScreen({super.key});

  @override
  State<AdminEditMonsterSelectionScreen> createState() => _AdminEditMonsterSelectionScreenState();
}

class _AdminEditMonsterSelectionScreenState extends State<AdminEditMonsterSelectionScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _monsters = [];
  bool _isLoading = true;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  Future<void> _loadMonsters() async {
    final data = await _adminService.getSpawnedMonsters();
    if (mounted) {
      setState(() {
        _monsters = data;
        _isLoading = false;
      });
    }
  }

  void _handleEdit() {
    if (_selectedId == null) return;
    final monster = _monsters.firstWhere((m) => m['id'] == _selectedId);
    context.push('/admin-edit-form', extra: monster);
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
          title: 'EDIT MONSTER',
          titleFontSize: 24,
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E1F)))
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _monsters.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final m = _monsters[index];
                          final id = m['id'] as int;
                          final isSelected = _selectedId == id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedId = id),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? Border.all(color: const Color(0xFF2C3E1F), width: 2) : null,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                              ),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: id,
                                    groupValue: _selectedId,
                                    activeColor: const Color(0xFF2C3E1F),
                                    onChanged: (val) => setState(() => _selectedId = val),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Image.network(m['sprite_url'] ?? '', filterQuality: FilterQuality.none),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m['name'] ?? 'UNKNOWN', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2C3E1F))),
                                        Text('TYPE: ${m['type'] ?? 'UNKNOWN'}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF2C3E1F))),
                                        const Text('SPAWN LOCATION:', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 9, color: Color(0xFF2C3E1F))),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('LATITUDE: ${m['latitude']?.toStringAsFixed(6)}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 8, color: Color(0xFF2C3E1F))),
                                              Text('LONGITUDE: ${m['longitude']?.toStringAsFixed(6)}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 8, color: Color(0xFF2C3E1F))),
                                              Text('RADIUS: ${m['radius']?.toStringAsFixed(2)}m', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 8, color: Color(0xFF2C3E1F))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: _selectedId == null ? null : _handleEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA50000),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.black, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('EDIT', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
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
