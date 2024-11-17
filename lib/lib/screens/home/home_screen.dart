// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:tf_202402/screens/art/editor_page.dart';
import 'package:tf_202402/screens/art/gallery_page.dart';
import 'package:tf_202402/screens/home/home_page.dart';
import 'package:tf_202402/screens/profile/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Método para obtener el contenido según el índice seleccionado
  Widget _getContentForIndex(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const EditorPage();
      case 2:
        return const GalleryPage();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getContentForIndex(_currentIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7B7A3), Color(0xFFFFD6C4)], // Degradado
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFFF76054), // Color seleccionado
            unselectedItemColor: const Color(0xFF8E8E8E), // Color no seleccionado
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.build),
                label: 'Editor',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo),
                label: 'Galería',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
