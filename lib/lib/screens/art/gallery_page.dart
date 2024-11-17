import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final user = _auth.currentUser;
    if (user != null) {
      final ListResult result = await _storage.ref('/user-gallery/${user.uid}').listAll();
      List<String> urls = [];
      for (var ref in result.items) {
        final url = await ref.getDownloadURL();
        urls.add(url);
      }
      setState(() {
        _imageUrls = urls;
        _isLoading = false;
      });
    }
  }

  void _openImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // Cierra la ventana flotante al hacer tap fuera
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {}, // Evita que el gesto cierre la ventana si se hace tap en la imagen
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Galería de Imágenes',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 20),
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF7B7A3)), // Salmón pastel
              )
            : _imageUrls.isEmpty
                ? const Center(
                    child: Text(
                      'No images in the gallery.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF665A5A), // Marrón suave
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _openImage(context, _imageUrls[index]), // Abre la ventana flotante
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8), // Bordes redondeados
                          child: Image.network(
                            _imageUrls[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                  color: const Color(0xFFF7B7A3), // Salmón pastel
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              color: Color(0xFF665A5A), // Marrón suave
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
