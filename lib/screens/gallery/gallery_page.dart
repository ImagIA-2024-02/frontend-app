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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Page'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imageUrls.isEmpty
              ? const Center(child: Text('No images in gallery'))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(_imageUrls[index], fit: BoxFit.cover);
                  },
                ),
    );
  }
}
