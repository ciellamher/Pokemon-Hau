import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:pokemon_hau/features/admin/admin_dashboard_screen.dart';
import 'package:pokemon_hau/features/admin/monster_control_center.dart';
import 'package:pokemon_hau/features/admin/admin_map_screen.dart';
import 'package:pokemon_hau/features/admin/add_monster_form_screen.dart';
import 'package:pokemon_hau/features/admin/monster_added_screen.dart';
import 'package:pokemon_hau/features/admin/admin_monster_list_screen.dart';
import 'package:pokemon_hau/features/admin/admin_edit_monster_selection_screen.dart';
import 'package:pokemon_hau/features/admin/admin_edit_monster_form_screen.dart';
import 'package:pokemon_hau/core/widgets/system_status_wrapper.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide mobile navbar and status bar (fullscreen)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
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
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final showControl = extra?['show_control'] as bool? ?? false;
        return CustomTransitionPage(
          child: BackgroundWrapper(child: DashboardScreen(showControl: showControl)),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        );
      },
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
    GoRoute(
      path: '/admin-dashboard',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: AdminDashboardScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/monster-control',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: MonsterControlCenter()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/admin-map',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: AdminMapScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/add-monster-form',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CustomTransitionPage(
          child: BackgroundWrapper(
            child: AddMonsterFormScreen(
              lat: extra['lat'] as double,
              lng: extra['lng'] as double,
              radius: extra['radius'] as double,
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        );
      },
    ),
    GoRoute(
      path: '/monster-added',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CustomTransitionPage(
          child: BackgroundWrapper(
            child: MonsterAddedScreen(
              name: extra['name'] as String,
              type: extra['type'] as String,
              spriteUrl: extra['sprite_url'] as String,
              id: extra['id'] as String,
              lat: extra['lat'] as double,
              lng: extra['lng'] as double,
              radius: extra['radius'] as double,
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        );
      },
    ),
    GoRoute(
      path: '/admin-monster-list',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: AdminMonsterListScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/admin-edit-selection',
      pageBuilder: (context, state) => CustomTransitionPage(
          child: const BackgroundWrapper(child: AdminEditMonsterSelectionScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
              FadeTransition(opacity: animation, child: child),
        ),
    ),
    GoRoute(
      path: '/admin-edit-form',
      pageBuilder: (context, state) {
        final monster = state.extra as Map<String, dynamic>;
        return CustomTransitionPage(
          child: BackgroundWrapper(child: AdminEditMonsterFormScreen(monster: monster)),
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
      builder: (context, child) {
        return SystemStatusWrapper(child: child!);
      },
    );
  }
}
