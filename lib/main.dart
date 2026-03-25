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
import 'package:pokemon_hau/features/ranking/ranking_screen.dart';
import 'package:pokemon_hau/features/settings/settings_screen.dart';
import 'package:pokemon_hau/features/settings/edit_profile_screen.dart';
import 'package:pokemon_hau/features/settings/about_us_screen.dart';
import 'package:pokemon_hau/features/pokemon/monster_library_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
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
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: MonsterLibraryScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/rankings',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: RankingScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: SettingsScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/edit-profile',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: EditProfileScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/about-us',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: AboutUsScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
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
