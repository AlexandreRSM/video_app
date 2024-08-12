import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageEditorPage extends StatefulWidget {
  const ImageEditorPage({super.key});

  @override
  _ImageEditorPageState createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _editImage() async {
    if (_selectedImage != null) {
      final editedImage = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: _selectedImage!,
        ),
      ));

      if (editedImage != null) {
        setState(() {
          _selectedImage = editedImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor Plus'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: _selectedImage == null ? null : _editImage,
            tooltip: 'Edit Image',
          ),
          IconButton(
            icon: Icon(
              Icons.image,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: _pickImage,
            tooltip: 'Pick Image',
          ),
        ],
      ),
      body: Center(
        child: _selectedImage == null
            ? Text(
          'No image selected.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        )
            : Image.file(_selectedImage!),
      ),
    );
  }
}
