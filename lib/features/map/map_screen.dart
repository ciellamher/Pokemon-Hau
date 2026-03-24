import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _initialPosition = const LatLng(15.1332210, 120.5910000); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: MascotCard(
            hasBackButton: true,
            onBackPressed: () => context.pop(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  // Map View
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black26, width: 2),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _initialPosition,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.pokemon_hau',
                        ),
                      ],
                    ),
                  ),
                  
                  // Red coordinates box 
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA50000), // Dark Red
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LAT: ${_initialPosition.latitude.toStringAsFixed(7)} LONG: ${_initialPosition.longitude.toStringAsFixed(7)}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'RADIUS: 100.00m',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
