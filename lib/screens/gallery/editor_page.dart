import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/gallery/artwork_recognition_page.dart';
import 'package:tf_202402/screens/gallery/artwork_restoration_page.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor Page'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navegar a la página de restauración de imágenes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArtworkRestorationPage(),
                  ),
                );
              },
              child: const Text("Restoration Image"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a la página de reconocimiento de imágenes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArtworkRecognitionPage(),
                  ),
                );
              },
              child: const Text("Recognition Image"),
            ),
          ],
        ),
      ),
    );
  }
}
