import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/logo.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            
            // Title and Subtitle
            const Text(
              'IMAGIA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Beautiful Present, & Future',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
                    GoRouter.of(context).go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, 
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
                
                const SizedBox(width: 16),
                
                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/register');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Divider with "Or" text
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    endIndent: 8,
                    indent: 40,
                  ),
                ),
                Text(
                  'Or',
                  style: TextStyle(color: Colors.grey),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                    endIndent: 40,
                    indent: 8,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Social Media Login Options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Facebook Login
                IconButton(
                  icon: const Icon(Icons.facebook),
                  color: Colors.grey,
                  iconSize: 30,
                  onPressed: () {
                    // Handle Facebook login
                  },
                ),
                
                const SizedBox(width: 20),
                
                // Google Login
                IconButton(
                  icon: const Icon(Icons.g_mobiledata),
                  color: Colors.grey,
                  iconSize: 30,
                  onPressed: () {
                    // Handle Google login
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
