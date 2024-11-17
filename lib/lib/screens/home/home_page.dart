// ignore_for_file: library_private_types_in_public_api

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    GoRouter.of(context).go('/auth');
  }

  Future<void> _loadImages() async {
  final User? user = _auth.currentUser;

  if (user != null) {
    try {
      final ListResult result =
          await _storage.ref('/user-gallery/${user.uid}').listAll();

      List<String> urls = [];
      for (var ref in result.items) {
        final String url = await ref.getDownloadURL();
        urls.add(url);
      }

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _imageUrls = urls;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle any errors
      print("Error loading images: $e");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PictorIA',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7B7A3), // Soft pastel salmon
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4E3), Color(0xFFFFD6C4)], // Background gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Hola, bienvenido(a) a \nPictorIA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333), // Dark gray
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFFF7B7A3)) // Pastel salmon
              else if (_imageUrls.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'The gallery is empty. Start adding some images!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF665A5A), // Soft brown
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: _imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    text: "Ir al Editor",
                    onPressed: () {
                      GoRouter.of(context).go('/editor');
                    },
                  ),
                  const SizedBox(width: 20),
                  GradientButton(
                    text: "Ir a la Galería",
                    onPressed: () {
                      GoRouter.of(context).go('/gallery');
                    },
                  ),
                ],
              ),
              const Spacer(),
              
            ],
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF7B7A3), Color(0xFFFA8072)], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
