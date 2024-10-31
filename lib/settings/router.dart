
import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/auth/login_or_register_screen.dart';
import 'package:tf_202402/screens/gallery/editor_page.dart';
import 'package:tf_202402/screens/gallery/gallery_page.dart';
import 'package:tf_202402/screens/home/home_screen.dart';
import 'package:tf_202402/screens/home/start_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder:(context, state) => const StartScreen(),
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