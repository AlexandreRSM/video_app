import 'package:flutter/material.dart';
import 'dart:io';
import 'full_screen_image.dart';

class FramesGalleryPage extends StatefulWidget {
  final String framesDirPath;

  const FramesGalleryPage({super.key, required this.framesDirPath});

  @override
  _FramesGalleryPageState createState() => _FramesGalleryPageState();
}

class _FramesGalleryPageState extends State<FramesGalleryPage> {
  late List<FileSystemEntity> _frames;
  final List<FileSystemEntity> _selectedFrames = [];

  @override
  void initState() {
    super.initState();
    _loadFrames();
  }

  Future<void> _loadFrames() async {
    final directory = Directory(widget.framesDirPath);
    setState(() {
      _frames = directory.listSync().where((file) => file.path.endsWith('.jpg')).toList();
    });
  }

  void _toggleSelection(FileSystemEntity frame) {
    setState(() {
      if (_selectedFrames.contains(frame)) {
        _selectedFrames.remove(frame);
      } else {
        _selectedFrames.add(frame);
      }
    });
  }

  void _deleteSelectedFrames() {
    for (var frame in _selectedFrames) {
      File(frame.path).deleteSync();
    }
    _selectedFrames.clear();
    _loadFrames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frames Gallery'),
        actions: [
          if (_selectedFrames.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedFrames,
              tooltip: 'Delete Selected Frames',
            ),
        ],
      ),
      body: _frames.isEmpty
          ? const Center(child: Text('No frames found.'))
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _frames.length,
        itemBuilder: (context, index) {
          final frame = _frames[index];
          final isSelected = _selectedFrames.contains(frame);

          return GestureDetector(
            onTap: () {
              if (_selectedFrames.isNotEmpty) {
                _toggleSelection(frame);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImage(
                      imagePath: frame.path,
                      themeMode: ThemeMode.system,
                    ),
                  ),
                );
              }
            },
            onLongPress: () => _toggleSelection(frame),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(frame.path),
                  fit: BoxFit.cover,
                ),
                if (isSelected)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
