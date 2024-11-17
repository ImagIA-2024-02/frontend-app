import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/auth/auth_wrapper.dart';
import 'package:tf_202402/screens/auth/login_or_register_screen.dart';
import 'package:tf_202402/screens/art/editor_page.dart';
import 'package:tf_202402/screens/art/gallery_page.dart';
import 'package:tf_202402/screens/home/home_screen.dart';
import 'package:tf_202402/screens/home/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/splash', // Hacemos del SplashScreen la ruta inicial
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(), // Pantalla de carga personalizada
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/loginOrRegister',
      builder: (context, state) => const LoginOrRegisterScreen(),
    ),
    GoRoute(
      path: '/home', 
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/gallery', 
      builder: (context, state) => const GalleryPage(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const EditorPage(),
    ),
  ],
  debugLogDiagnostics: true,
);
