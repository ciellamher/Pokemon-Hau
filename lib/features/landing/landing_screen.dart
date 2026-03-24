import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/breathing_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Branding graphic
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset(
                'Assets/Images/branding.png', 
                height: 350, 
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 60),

            // Breathing Play Button
            BreathingWidget(
              child: GestureDetector(
                onTap: () {
                  context.push('/signin');
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA50000), // Dark red from design
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
