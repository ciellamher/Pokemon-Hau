import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class AdminMonsterListScreen extends StatefulWidget {
  const AdminMonsterListScreen({super.key});

  @override
  State<AdminMonsterListScreen> createState() => _AdminMonsterListScreenState();
}

class _AdminMonsterListScreenState extends State<AdminMonsterListScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _monsters = [];
  bool _isLoading = true;
  final Set<int> _selectedIds = {};
  bool _showConfirm = false;
  bool _showDeleted = false;

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  Future<void> _loadMonsters() async {
    setState(() => _isLoading = true);
    final data = await _adminService.getSpawnedMonsters();
    if (mounted) {
      setState(() {
        _monsters = data;
        _isLoading = false;
        _selectedIds.clear();
      });
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.addAll(_monsters.map((m) => m['id'] as int));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _handleDelete() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _showConfirm = true);
  }

  Future<void> _confirmDelete() async {
    final success = await _adminService.deleteSpawnedMonsters(_selectedIds.toList());
    if (success && mounted) {
      setState(() {
        _showConfirm = false;
        _showDeleted = true;
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
              height: double.infinity,
              title: 'DELETE MONSTER',
              titleFontSize: 24,
              showShadow: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _monsters.isNotEmpty && _selectedIds.length == _monsters.length,
                            onChanged: _toggleSelectAll,
                            activeColor: const Color(0xFF2C3E1F),
                          ),
                          const Text('SELECT ALL', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Use Expanded to let the ListView take available space, 
                  // but wrap in a container to ensure it has room
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E1F)))
                        : _monsters.isEmpty
                            ? const Center(child: Text('No monsters spawned yet.', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900)))
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: _monsters.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final m = _monsters[index];
                                  final id = m['id'] as int;
                                  final isSelected = _selectedIds.contains(id);
                                  return GestureDetector(
                                    onTap: () => _toggleSelect(id),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: isSelected ? Border.all(color: const Color(0xFF2C3E1F), width: 2) : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (_) => _toggleSelect(id),
                                            activeColor: const Color(0xFF2C3E1F),
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
                                                Text('Monster Name: ${m['name'] ?? 'UNKNOWN'}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2C3E1F))),
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
                  
                  // Bottom button area
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _selectedIds.isEmpty ? null : _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA50000),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('DELETE', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirmation Dialog
          if (_showConfirm) _buildConfirmOverlay(),

          // Success Dialog
          if (_showDeleted) _buildDeletedOverlay(),
        ],
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  Widget _buildConfirmOverlay() {
    final selectedMonsters = _monsters.where((m) => _selectedIds.contains(m['id'])).toList();
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MascotCard(
              showShadow: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'DELETE MONSTERS?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: selectedMonsters.map((m) => Text(
                          'MONSTER NAME: ${m['name']}',
                          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF2C3E1F)),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _showConfirm = false),
                          child: const Text('GO BACK', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2C3E1F))),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _confirmDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA50000),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('YES', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MascotCard(
              showShadow: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MONSTERS DELETED',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2C3E1F)),
                  ),
                  const SizedBox(height: 30),
                  Image.asset('Assets/Images/bin.png', height: 100),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () => context.go('/admin-dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA50000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('GO BACK', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
