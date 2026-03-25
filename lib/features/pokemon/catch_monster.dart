import 'package:flutter/material.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';

class CatchMonsterDialog extends StatelessWidget {
  final PokemonModel pokemon;
  final VoidCallback onBack;
  final VoidCallback onDetectAgain;

  const CatchMonsterDialog({
    super.key,
    required this.pokemon,
    required this.onBack,
    required this.onDetectAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF3D7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF2C3E1F), width: 6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CONGRATULATIONS,',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C3E1F),
              ),
            ),
            Text(
              'YOU CAUGHT A\n${pokemon.name}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C3E1F),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.network(
                  pokemon.spriteUrl,
                  height: 150,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2C3E1F),
                      side: const BorderSide(color: Color(0xFF2C3E1F), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('GO BACK', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDetectAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA50000),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('DETECT AGAIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
