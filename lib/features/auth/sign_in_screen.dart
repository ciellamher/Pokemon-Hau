import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';
import 'package:pokemon_hau/core/widgets/custom_text_field.dart';
import 'package:pokemon_hau/core/widgets/breathing_widget.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: BreathingWidget(
              child: MascotCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SIGN IN',
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
                    
                    const CustomTextField(label: 'USERNAME:'),
                    const SizedBox(height: 20),
                    const CustomTextField(label: 'PASSWORD:', isPassword: true),
                    
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: false,
                            onChanged: (val) {},
                            fillColor: WidgetStateProperty.all(Colors.grey.shade300),
                            checkColor: Colors.black,
                            side: BorderSide.none,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          // Mock auth: just go to dashboard
                          context.go('/dashboard');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA50000), // Dark Red
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Color(0xFF1F385C), width: 3), // Dark outline
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'SIGN IN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        context.push('/signup');
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Sign up here.',
                              style: TextStyle(color: Color(0xFFA50000)),
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
      ),
    );
  }
}
