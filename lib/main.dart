import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pokemon_hau/core/services/audio_service.dart';
import 'package:pokemon_hau/core/widgets/background_wrapper.dart';
import 'package:pokemon_hau/features/landing/landing_screen.dart';
import 'package:pokemon_hau/features/auth/sign_in_screen.dart';
import 'package:pokemon_hau/features/auth/sign_up_screen.dart';
import 'package:pokemon_hau/features/dashboard/dashboard_screen.dart';
import 'package:pokemon_hau/features/map/map_screen.dart';
import 'package:pokemon_hau/features/pokemon/monster_library_screen.dart';
import 'package:pokemon_hau/features/pokemon/pokemon_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    // Initialize Supabase only if valid configuration is present
    if (supabaseUrl.isNotEmpty && 
        supabaseAnonKey.isNotEmpty && 
        supabaseUrl != 'https://your-project-url.supabase.co') {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint('Initialization warning: $e');
  }

  // Start background music loop
  AudioService().initBackgroundMusic();

  runApp(const HauPokemonApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const BackgroundWrapper(child: LandingScreen()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => 
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/signin',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const BackgroundWrapper(child: SignInScreen()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => 
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const BackgroundWrapper(child: SignUpScreen()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => 
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const BackgroundWrapper(child: DashboardScreen()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => 
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/map',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const BackgroundWrapper(child: MapScreen()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => 
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/library',
      pageBuilder: (context, state) {
        final pokemons = state.extra as List<PokemonModel>? ?? [];
        return CustomTransitionPage(
          child: BackgroundWrapper(child: MonsterLibraryScreen(pokemons: pokemons)),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        );
      },
    ),
  ],
);

class HauPokemonApp extends StatelessWidget {
  const HauPokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hau Pokemon',
      routerConfig: _router,
      theme: ThemeData(
        fontFamily: 'Montserrat', // Default to Montserrat
        primaryColor: const Color(0xFFA50000), // Dark Red 
        scaffoldBackgroundColor: Colors.transparent, // Let BackgroundWrapper show
      ),
    );
  }
}
