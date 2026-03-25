import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';

class MonsterAddedScreen extends StatelessWidget {
  final String name;
  final String type;
  final String spriteUrl;
  final String id;
  final double lat;
  final double lng;
  final double radius;

  const MonsterAddedScreen({
    super.key,
    required this.name,
    required this.type,
    required this.spriteUrl,
    required this.id,
    required this.lat,
    required this.lng,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen map behind everything
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.pokemon_hau',
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(lat, lng),
                            radius: radius,
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
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: Image.network(spriteUrl, filterQuality: FilterQuality.none),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Overlay card on top of map
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).size.height * 0.18,
              bottom: 120, // Keep it above the navbar area
              child: MascotCard(
                height: double.infinity,
                title: 'MONSTER ADDED!',
                titleFontSize: 26,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Info card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Sprite
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Image.network(
                                          spriteUrl,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.none,
                                          errorBuilder: (ctx, err, stack) => const Icon(Icons.catching_pokemon, size: 60),
                                        ),
                                      ),
                                      Text(
                                        id,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: Color(0xFF2C3E1F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MONSTER NAME: $name',
                                          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF2C3E1F)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'TYPE: $type',
                                          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF2C3E1F)),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'SPAWN LOCATION:',
                                          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF2C3E1F)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'LATITUDE: ${lat.toStringAsFixed(7)}',
                                                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E1F)),
                                              ),
                                              Text(
                                                'LONGITUDE: ${lng.toStringAsFixed(7)}',
                                                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E1F)),
                                              ),
                                              Text(
                                                'RADIUS: ${radius.toStringAsFixed(2)}m',
                                                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E1F)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Go Back button - Fixed at the bottom of the card
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => context.go('/admin-dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA50000),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('GO BACK', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
