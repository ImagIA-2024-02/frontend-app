
import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/auth/auth_wrapper.dart';
import 'package:tf_202402/screens/auth/login_or_register_screen.dart';
import 'package:tf_202402/screens/auth/login_screen.dart';
import 'package:tf_202402/screens/auth/register_screen.dart';
import 'package:tf_202402/screens/gallery/editor_page.dart';
import 'package:tf_202402/screens/gallery/gallery_page.dart';
import 'package:tf_202402/screens/home/home_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder:(context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/loginOrRegister',
      builder: (context, state) => const LoginOrRegisterScreen(),
    ),
    GoRoute(
      path: '/login', 
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register', 
      builder: (context, state) => const RegisterScreen(),
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