import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tf_202402/screens/auth/widgets/auth_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailController.text.trim());

      showDialog(
        // ignore: use_build_context_synchronously
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: const Text('If the email exists, a password reset link will be sent to your email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

    } on FirebaseAuthException catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: Text(e.message.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Forgot Password'),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              'Enter your email address to reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),  
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Email',
                fillColor: Colors.grey[200],
                filled: true, 
              ),
            ),
          ),
          const SizedBox(height: 10),
          AuthButton(
            onTap: passwordReset,
            text: 'Reset Password',
          ),
        ],
      ),
    );
  }
}