import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class AddMonsterFormScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final double radius;

  const AddMonsterFormScreen({
    super.key,
    required this.lat,
    required this.lng,
    required this.radius,
  });

  @override
  State<AddMonsterFormScreen> createState() => _AddMonsterFormScreenState();
}

class _AddMonsterFormScreenState extends State<AddMonsterFormScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _pokemonList = [];
  Map<String, dynamic>? _selectedPokemon;
  Map<String, dynamic>? _pokemonDetails;
  bool _isLoadingList = true;
  bool _isLoadingDetails = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPokemonList();
  }

  Future<void> _loadPokemonList() async {
    final list = await _adminService.fetchPokemonList(limit: 50);
    if (mounted) {
      setState(() {
        _pokemonList = list;
        _isLoadingList = false;
      });
    }
  }

  Future<void> _onPokemonSelected(Map<String, dynamic> pokemon) async {
    setState(() {
      _selectedPokemon = pokemon;
      _isLoadingDetails = true;
      _pokemonDetails = null;
    });

    final details = await _adminService.fetchPokemonDetails(pokemon['url']);
    if (mounted) {
      setState(() {
        _pokemonDetails = details;
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _confirmMonster() async {
    if (_pokemonDetails == null) return;

    setState(() => _isSaving = true);

    final success = await _adminService.spawnMonster(
      pokemonId: _pokemonDetails!['id'],
      name: _pokemonDetails!['name'],
      type: _pokemonDetails!['type'],
      spriteUrl: _pokemonDetails!['sprite_url'],
      lat: widget.lat,
      lng: widget.lng,
      radius: widget.radius,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        context.push('/monster-added', extra: {
          'name': _pokemonDetails!['name'],
          'type': _pokemonDetails!['type'],
          'sprite_url': _pokemonDetails!['sprite_url'],
          'id': _pokemonDetails!['id'].toString().padLeft(3, '0'),
          'lat': widget.lat,
          'lng': widget.lng,
          'radius': widget.radius,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to spawn monster. Check your database setup.', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF7A0000),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
            title: 'ADD MONSTER',
            titleFontSize: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Sprite preview
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C3E1F), width: 2),
                  ),
                  child: _isLoadingDetails
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E1F)))
                      : _pokemonDetails != null
                          ? Image.network(
                              _pokemonDetails!['sprite_url'],
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 60, color: Colors.grey),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 50, color: Colors.grey.shade400),
                                Text('ADD IMAGE', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey.shade400)),
                              ],
                            ),
                ),
                const SizedBox(height: 20),

                // Pokemon dropdown/search
                _isLoadingList
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: Color(0xFF2C3E1F)),
                      )
                    : _buildField(
                        'MONSTER NAME:',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPokemon?['name'],
                            isExpanded: true,
                            hint: const Text('SELECT POKEMON', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14)),
                            items: _pokemonList.map((p) {
                              return DropdownMenuItem(
                                value: p['name'] as String,
                                child: Text(p['name'] as String, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (name) {
                              final selected = _pokemonList.firstWhere((p) => p['name'] == name);
                              _onPokemonSelected(selected);
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 12),

                // Auto-filled fields
                _buildReadOnlyField('TYPE:', _pokemonDetails?['type'] ?? ''),
                const SizedBox(height: 12),
                _buildReadOnlyField('LATITUDE:', widget.lat.toStringAsFixed(7)),
                const SizedBox(height: 12),
                _buildReadOnlyField('LONGITUDE:', widget.lng.toStringAsFixed(7)),
                const SizedBox(height: 12),
                _buildReadOnlyField('RADIUS:', '${widget.radius.toStringAsFixed(2)}m'),
                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (_pokemonDetails != null && !_isSaving) ? _confirmMonster : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA50000),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isSaving
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('CONFIRM', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 18)),
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

  Widget _buildField(String label, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E1F))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2C3E1F), width: 2),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E1F))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2C3E1F), width: 2),
          ),
          child: Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2C3E1F)),
          ),
        ),
      ],
    );
  }
}
