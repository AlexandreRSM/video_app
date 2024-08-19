import 'package:flutter/material.dart';
import 'dart:io';

class FramesGalleryPage extends StatelessWidget {
  final String framesDirPath;

  const FramesGalleryPage({super.key, required this.framesDirPath});

  @override
  Widget build(BuildContext context) {
    final framesDir = Directory(framesDirPath);
    final frames = framesDir.listSync().where((file) => file.path.endsWith('.jpg')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frames Gallery'),
      ),
      body: frames.isEmpty
          ? const Center(child: Text('No frames found.'))
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: frames.length,
        itemBuilder: (context, index) {
          final frame = frames[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Image.file(File(frame.path)),
                ),
              );
            },
            child: Image.file(
              File(frame.path),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
