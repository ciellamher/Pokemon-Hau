import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: MascotCard(
              hasBackButton: true,
              onBackPressed: () => context.pop(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SIGN UP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  const CustomTextField(label: 'EMAIL:'),
                  const SizedBox(height: 15),
                  const CustomTextField(label: 'USERNAME:'),
                  const SizedBox(height: 15),
                  const CustomTextField(label: 'PLAYER NAME:'),
                  const SizedBox(height: 15),
                  const CustomTextField(label: 'PASSWORD:', isPassword: true),
                  const SizedBox(height: 15),
                  const CustomTextField(label: 'CONFIRM PASSWORD:', isPassword: true),
                  const SizedBox(height: 30),
                  
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mock auth: just go to dashboard after signing up
                        context.go('/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA50000), // Dark Red
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Color(0xFF1F385C), width: 3),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
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
