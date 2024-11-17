import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onTap});
  final Function()? onTap;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;
  String? _ageError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isFormValid = false; // Track form validity

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUserUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await _addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          int.parse(_ageController.text.trim()),
          _emailController.text.trim(),
        );

        Navigator.pop(context);
        GoRouter.of(context).go('/home');
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        _showErrorMessage(e.message ?? 'Error al registrarse');
      }
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUserDetails(
      String firstName, String lastName, int age, String email) async {
    await FirebaseFirestore.instance.collection('users').add({
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'email': email,
    });
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = (_firstNameError == null &&
          _lastNameError == null &&
          _ageError == null &&
          _emailError == null &&
          _passwordError == null &&
          _confirmPasswordError == null &&
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _ageController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4E3), Color(0xFFF7B7A3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: Color(0xFF1A2A56), size: 36),
                        SizedBox(width: 8),
                        Text(
                          'PictorIA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2A56),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡Bienvenido(a)! \nInscríbete para seguir disfrutando \nde las ventajas de PictorIA.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF665A5A),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: const TextStyle(color: Color(0xFF665A5A)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF7B7A3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _firstNameError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _firstNameError =
                              value.isEmpty ? 'El nombre es obligatorio' : null;
                          _updateFormValidity();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        labelStyle: const TextStyle(color: Color(0xFF665A5A)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF7B7A3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _lastNameError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _lastNameError =
                              value.isEmpty ? 'El apellido es obligatorio' : null;
                          _updateFormValidity();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Edad',
                        labelStyle: const TextStyle(color: Color(0xFF665A5A)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF7B7A3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _ageError,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          final age = int.tryParse(value);
                          _ageError = value.isEmpty
                              ? 'La edad es obligatoria'
                              : (age == null || age <= 0
                                  ? 'Por favor, ingrese una edad válida'
                                  : null);
                          _updateFormValidity();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo',
                        labelStyle: const TextStyle(color: Color(0xFF665A5A)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF7B7A3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          _emailError = value.isEmpty
                              ? 'El correo es obligatorio'
                              : (!emailRegex.hasMatch(value)
                                  ? 'Por favor, ingrese un correo válido'
                                  : null);
                          _updateFormValidity();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Color(0xFF665A5A)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF7B7A3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _passwordError,
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _passwordError = value.isEmpty
                              ? 'La contraseña es obligatoria'
                              : (value.length < 6
                                  ? 'La contraseña debe tener al menos 6 caracteres'
                                  : null);
                          _updateFormValidity();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        labelStyle: const TextStyle(color: Color(0xFF665A5A)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFF7B7A3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _confirmPasswordError,
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _confirmPasswordError = value.isEmpty
                              ? 'Debe confirmar su contraseña'
                              : (value != _passwordController.text
                                  ? 'Las contraseñas no coinciden'
                                  : null);
                          _updateFormValidity();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid ? _signUserUp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? const Color(0xFF1A2A56)
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes una cuenta? ',
                            style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(
                                  onTap: widget.onTap,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(color: Color(0xFFFA8072)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
