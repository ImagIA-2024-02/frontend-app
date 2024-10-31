// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:tf_202402/screens/gallery/editor_page.dart';
import 'package:tf_202402/screens/gallery/gallery_page.dart';
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Restore Lab',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
