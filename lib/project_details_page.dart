import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_app/ffmpeg_works.dart'; // Importa a classe FFmpegWorks
import 'package:flutter_video_app/video_page.dart';
import 'frames_gallery_page.dart';

class ProjectDetailsPage extends StatelessWidget {
  final String videoPath;

  const ProjectDetailsPage({Key? key, required this.videoPath, String? framesDirPath, required String projectPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Watch Video'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(videoPath: videoPath),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Generate Frames'),
            onTap: () async {
              await FFmpegWorks.convertVideoToFrames(videoPath); // Usa a função corretamente
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FramesGalleryPage(framesDirPath: Directory(videoPath).parent.path),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
