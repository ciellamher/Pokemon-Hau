import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: MascotCard(
            hasBackButton: true,
            onBackPressed: () => context.pop(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'EDIT PROFILE',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2C3E1F),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildEditField('NEW PLAYER NAME:'),
                  const SizedBox(height: 16),
                  _buildEditField('CURRENT PASSWORD:'),
                  const SizedBox(height: 16),
                  _buildEditField('NEW PASSWORD:'),
                  const SizedBox(height: 16),
                  _buildEditField('CONFIRM NEW PASSWORD:'),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A0000), // Dark red
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  Widget _buildEditField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: Color(0xFF2C3E1F),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF2C3E1F), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF2C3E1F), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
