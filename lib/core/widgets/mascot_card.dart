import 'package:flutter/material.dart';
import 'package:pokemon_hau/core/widgets/stroke_text.dart';

class MascotCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final bool hasBackButton;
  final VoidCallback? onBackPressed;
  final String? title;
  final double titleFontSize;
  final bool showShadow;
  
  const MascotCard({
    super.key, 
    required this.child, 
    this.width = double.infinity,
    this.height,
    this.hasBackButton = false,
    this.onBackPressed,
    this.title,
    this.titleFontSize = 24,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(top: 60), // Space for mascot
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF3D7), // Light yellowish-cream
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C3E1F), width: 6), // Dark greenish border from screenshot
            boxShadow: showShadow ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (title != null) ...[
                const SizedBox(height: 20),
                StrokeText(
                  text: title!,
                  fontSize: titleFontSize,
                  letterSpacing: titleFontSize * 0.04,
                ),
                const SizedBox(height: 16),
              ],
              height != null 
                  ? Expanded(child: child) 
                  : Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: child,
                      ),
                    ),
            ],
          ),
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
