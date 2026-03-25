import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/services/admin_service.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  double _radius = 100.0;
  List<Map<String, dynamic>> _existingSpawns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingSpawns();
  }

  Future<void> _loadExistingSpawns() async {
    final spawns = await AdminService().getSpawnedMonsters();
    if (mounted) {
      setState(() {
        _existingSpawns = spawns;
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
              // Map
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(15.1332210, 120.5910000),
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.pokemon_hau',
                      ),
                      // Existing spawns
                      if (!_isLoading) ...[
                        CircleLayer(
                          circles: _existingSpawns.map((p) => CircleMarker(
                            point: LatLng((p['latitude'] as num).toDouble(), (p['longitude'] as num).toDouble()),
                            radius: (p['radius'] as num).toDouble(),
                            useRadiusInMeter: true,
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 1,
                          )).toList(),
                        ),
                        MarkerLayer(
                          markers: _existingSpawns.map((p) => Marker(
                            point: LatLng((p['latitude'] as num).toDouble(), (p['longitude'] as num).toDouble()),
                            width: 30,
                            height: 30,
                            child: Image.network(
                              p['sprite_url'],
                              filterQuality: FilterQuality.none,
                              errorBuilder: (c, e, s) => const Icon(Icons.catching_pokemon, color: Colors.blue, size: 20),
                            ),
                          )).toList(),
                        ),
                      ],

                      // New selection
                      if (_selectedLocation != null) ...[
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: _selectedLocation!,
                              radius: _radius,
                              useRadiusInMeter: true,
                              color: const Color(0xFFA50000).withValues(alpha: 0.15),
                              borderColor: const Color(0xFFA50000),
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Color(0xFFA50000),
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Coordinate display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA50000),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _selectedLocation != null
                      ? 'LAT: ${_selectedLocation!.latitude.toStringAsFixed(7)}  LONG: ${_selectedLocation!.longitude.toStringAsFixed(7)}\nRADIUS: ${_radius.toStringAsFixed(2)}m'
                      : 'TAP ON THE MAP TO PLACE A PIN',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Radius slider
              Row(
                children: [
                  const Text('RADIUS:', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF2C3E1F))),
                  Expanded(
                    child: Slider(
                      value: _radius,
                      min: 10,
                      max: 500,
                      activeColor: const Color(0xFFA50000),
                      onChanged: (v) => setState(() => _radius = v),
                    ),
                  ),
                  Text('${_radius.toInt()}m', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF2C3E1F))),
                ],
              ),
              const SizedBox(height: 8),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedLocation != null
                      ? () {
                          context.push('/add-monster-form', extra: {
                            'lat': _selectedLocation!.latitude,
                            'lng': _selectedLocation!.longitude,
                            'radius': _radius,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA50000),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.black, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('CONFIRM LOCATION', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 16)),
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
