// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? imageUrl;
  final Function(File) onImageSelected;
  final bool isEditing; // Added parameter to control edit mode

  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.onImageSelected,
    this.isEditing = false, // Defaults to non-editable
  });

  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.onImageSelected(_image!);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: _getBackgroundImage(),
        ),
        if (widget.isEditing) // Show overlay only in editing mode
          Positioned(
            child: GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (_image != null) {
      return FileImage(_image!);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return NetworkImage(widget.imageUrl!);
    }
    return null;
  }
}
