import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tf_202402/screens/profile/profile_image_picker.dart';
import 'package:tf_202402/utils/validators.dart';
import 'package:tf_202402/widgets/custom_button.dart';
import 'package:tf_202402/widgets/custom_text_form_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _profileImageUrl = '';
  bool _isLoading = true;
  DocumentReference? _userDocRef;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    GoRouter.of(context).go('/');
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userEmail = user.email ?? '';

        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot doc = querySnapshot.docs.first;
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          setState(() {
            _firstNameController.text = data['firstName'] ?? '';
            _lastNameController.text = data['lastName'] ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            _profileImageUrl = data['profileImageUrl'] ?? '';
            _userDocRef = doc.reference; // Store document reference for updates
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _userDocRef == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _userDocRef!.update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'profileImageUrl': _profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadImageToStorage(File image) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      Reference ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _profileImageUrl = downloadUrl;
      });

      if (_userDocRef != null) {
        await _userDocRef!.update({
          'profileImageUrl': _profileImageUrl,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          InkWell(
            onTap: () {
              _signOut(context);
              
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.logout,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileImagePicker(
                      imageUrl: _profileImageUrl,
                      onImageSelected: _uploadImageToStorage,
                    ),
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      controller: _firstNameController,
                      label: 'First Name',
                      validator: Validators.validateFirstName,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      validator: Validators.validateLastName,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _ageController,
                      label: 'Age',
                      validator: Validators.validateAge,
                      keyBoardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: _updateProfile,
                      buttonText: 'Update Profile',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
