import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/art/image_recognition_model.dart';
import 'package:tf_202402/screens/art/image_restoration_model.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editor de imágenes',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7B7A3), // Salmón pastel
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4E3), Color(0xFFFFD6C4)], // Fondo degradado suave
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título principal
              const Text(
                "Elija una opción",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF665A5A), // Marrón suave
                ),
              ),
              const SizedBox(height: 40),
              // Tarjeta de Restauración
              _buildActionCard(
                title: "Restaurar imagen",
                description: "Mejora y repara tus imágenes",
                icon: Icons.photo,
                iconColor: const Color(0xFFF7B7A3), // Salmón pastel
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageRestorationModel(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Tarjeta de Reconocimiento
              _buildActionCard(
                title: "Reconocer obras de arte",
                description: "Identificar y explorar los detalles de las obras de arte",
                icon: Icons.person,
                iconColor: const Color(0xFFFA8072), // Coral oscuro
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageRecognitionModel(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF333333), // Gris oscuro
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF665A5A), // Marrón suave
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
