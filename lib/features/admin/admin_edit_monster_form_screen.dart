import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class AdminEditMonsterFormScreen extends StatefulWidget {
  final Map<String, dynamic> monster;

  const AdminEditMonsterFormScreen({super.key, required this.monster});

  @override
  State<AdminEditMonsterFormScreen> createState() => _AdminEditMonsterFormScreenState();
}

class _AdminEditMonsterFormScreenState extends State<AdminEditMonsterFormScreen> {
  final AdminService _adminService = AdminService();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.monster['name']);
    _typeController = TextEditingController(text: widget.monster['type']);
    _latController = TextEditingController(text: widget.monster['latitude'].toString());
    _lngController = TextEditingController(text: widget.monster['longitude'].toString());
    _radiusController = TextEditingController(text: widget.monster['radius'].toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final success = await _adminService.updateSpawnedMonster(
      id: widget.monster['id'],
      name: _nameController.text,
      type: _typeController.text,
      lat: double.tryParse(_latController.text),
      lng: double.tryParse(_lngController.text),
      radius: double.tryParse(_radiusController.text),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        context.go('/admin-dashboard');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monster updated successfully!', style: TextStyle(fontWeight: FontWeight.bold))),
        );
      }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: MascotCard(
            title: 'EDIT MONSTER',
            titleFontSize: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Image placeholder
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2C3E1F), width: 2),
                  ),
                  child: widget.monster['sprite_url'] != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(widget.monster['sprite_url'], fit: BoxFit.contain, filterQuality: FilterQuality.none),
                            Positioned(
                              top: 5, right: 5,
                              child: Text('ADD IMAGE :', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 8, color: Colors.grey.shade400)),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 50, color: Colors.grey.shade400),
                              Text('ADD IMAGE :', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey.shade400)),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                _buildTextField('MONSTER NAME:', _nameController),
                const SizedBox(height: 12),
                _buildTextField('TYPE:', _typeController),
                const SizedBox(height: 12),
                _buildTextField('LATITUDE:', _latController),
                const SizedBox(height: 12),
                _buildTextField('LONGITUDE:', _lngController),
                const SizedBox(height: 12),
                _buildTextField('RADIUS:', _radiusController),
                const SizedBox(height: 24),

                SizedBox(
                  width: 160,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA50000),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SAVE', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 18)),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E1F))),
        const SizedBox(height: 4),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF2C3E1F), width: 2),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2C3E1F)),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
      ],
    );
  }
}
