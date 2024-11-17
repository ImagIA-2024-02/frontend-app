import 'package:flutter/material.dart';
import 'package:tf_202402/screens/auth/login_screen.dart';
import 'package:tf_202402/screens/auth/register_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool showLoginPage = true; // Track which screen to show

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage; // Toggle between Login and Register
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4E3), Color(0xFFF7B7A3)], // Beige to Salmon gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/logo.png'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 16),

              const Text(
                'IMAGIA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF1A2A56), // Navy Blue
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Beautiful Present, & Future',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF665A5A), // Soft Brown
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sign In Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showLoginPage = true; // Set to Login page
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginScreen(onTap: togglePages),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A2A56), // Navy Blue
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF1A2A56)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showLoginPage = false; // Set to Register page
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RegisterScreen(onTap: togglePages),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1A2A56), // Navy Blue
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
