import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/home/start_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/home');
            });
            return const SizedBox.shrink();
          } else {
            return const StartScreen();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
