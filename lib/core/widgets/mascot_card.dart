import 'package:flutter/material.dart';

class MascotCard extends StatelessWidget {
  final Widget child;
  final double width;
  final bool hasBackButton;
  final VoidCallback? onBackPressed;
  
  const MascotCard({
    super.key, 
    required this.child, 
    this.width = double.infinity,
    this.hasBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: width,
          margin: const EdgeInsets.only(top: 60), // Space for mascot
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF3D7), // Light yellowish-cream
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C3E1F), width: 6), // Dark greenish border from screenshot
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          top: 0,
          child: Image.asset(
            'Assets/Images/happybear.png', 
            height: 110,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 80),
          ),
        ),
        if (hasBackButton)
          Positioned(
            top: 80,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: onBackPressed,
            ),
          ),
      ],
    );
  }
}
