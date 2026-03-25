import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/custom_navbar.dart';
import 'package:pokemon_hau/core/widgets/mascot_card.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
            title: 'ABOUT US',
            titleFontSize: 30,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C3E1F), width: 2),
                    ),
                    child: const Text(
                      'Welcome to the HAUPokemon Expedition, a cloud-native monster-hunting initiative developed by THES-IS-IT at the Holy Angel University School of Computing. Our mission is to bridge the physical campus with the digital world, utilizing real-time GPS scanning to detect and capture unique monsters hidden across landmarks like the HAU Chapel and SJH Building. By participating in this journey, you are helping us test secure, high-availability mobile infrastructure while competing for the top spot on our Global Monster Hunter Leaderboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E1F),
                        height: 1.5,
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
}
