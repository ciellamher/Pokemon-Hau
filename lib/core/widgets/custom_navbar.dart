import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/widgets/breathing_widget.dart';

class CustomNavbar extends StatelessWidget {
  const CustomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // The three tabs
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left Tab (RANKINGS)
              Expanded(
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border(
                      top: BorderSide(color: Color(0xFF2C3E1F), width: 5),
                      left: BorderSide(color: Color(0xFF2C3E1F), width: 5),
                      right: BorderSide(color: Color(0xFF2C3E1F), width: 5),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Text label stays at the bottom
                      Positioned(
                        bottom: 12,
                        child: Stack(
                          children: [
                            Text(
                              'RANKINGS', 
                              style: TextStyle(
                                fontFamily: 'Montserrat', 
                                fontSize: 12, 
                                fontWeight: FontWeight.w900, 
                                letterSpacing: 1.0,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3
                                  ..color = const Color(0xFF2C3E1F)
                              )
                            ),
                            const Text(
                              'RANKINGS', 
                              style: TextStyle(
                                fontFamily: 'Montserrat', 
                                fontSize: 12, 
                                fontWeight: FontWeight.w900, 
                                letterSpacing: 1.0,
                                color: Colors.white
                              )
                            ),
                          ]
                        ),
                      ),
                      // Icon pops out of the top
                      Positioned(
                        bottom: 40,
                        child: Image.asset('Assets/Images/trophy.png', height: 75),
                      ),
                    ],
                  ),
                ),
              ),
              // Center Tab (CATCH MONSTER)
              Expanded(
                child: Container(
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCF3D7),
                    border: Border(
                      top: BorderSide(color: Color(0xFF2C3E1F), width: 5),
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      Text(
                        'CATCH MONSTER', 
                        style: TextStyle(
                          fontFamily: 'Montserrat', 
                          fontSize: 10, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 0.5,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = const Color(0xFF2C3E1F)
                        )
                      ),
                      const Text(
                        'CATCH MONSTER', 
                        style: TextStyle(
                          fontFamily: 'Montserrat', 
                          fontSize: 10, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 0.5,
                          color: Colors.white
                        )
                      ),
                    ]
                  ),
                ),
              ),
              // Right Tab (MAP)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/map');
                  },
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      border: Border(
                        top: BorderSide(color: Color(0xFF2C3E1F), width: 5),
                        left: BorderSide(color: Color(0xFF2C3E1F), width: 5),
                        right: BorderSide(color: Color(0xFF2C3E1F), width: 5),
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned(
                          bottom: 12,
                          child: Stack(
                            children: [
                              Text(
                                'MAP', 
                                style: TextStyle(
                                  fontFamily: 'Montserrat', 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w900, 
                                  letterSpacing: 1.0,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 3
                                    ..color = const Color(0xFF2C3E1F)
                                )
                              ),
                              const Text(
                                'MAP', 
                                style: TextStyle(
                                  fontFamily: 'Montserrat', 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w900, 
                                  letterSpacing: 1.0,
                                  color: Colors.white
                                )
                              ),
                            ]
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          child: Image.asset('Assets/Images/map.png', height: 75),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Overlapping Pokeball (Massive scale)
          Positioned(
            bottom: 30, // Rests on the center tab
            child: BreathingWidget(
              child: GestureDetector(
                onTap: () {},
                child: Image.asset(
                  'Assets/Images/pokeball.png',
                  height: 130, // Much larger icon size
                  width: 130,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
