import 'package:flutter/material.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animación del logo
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Navegar después de 3 segundos
    Timer(const Duration(seconds: 3), () {
     GoRouter.of(context).go('/auth');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF9EAE1), Color(0xFFFFD1C1)], // Crema y rosa pastel
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación del logo
              ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              // Texto personalizado
              const Text(
                "IMAGIA",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C757D), // Gris suave
                  fontFamily: 'Montserrat',
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Beautiful, Present, & Future",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C757D), // Gris suave
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              // Indicador de progreso
              const CircularProgressIndicator(
                color: Color(0xFFF9C49A), // Durazno suave
                strokeWidth: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
