import 'package:flutter/material.dart';
import 'package:flutter_video_app/videos_gallery_page.dart';
import 'dart:io';

import 'frames_gallery_page.dart';

class ProjectGalleryPage extends StatelessWidget {
  final Directory baseDir;

  const ProjectGalleryPage({super.key, required this.baseDir});

  @override
  Widget build(BuildContext context) {
    final projects = baseDir.listSync().whereType<Directory>().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Gallery'),
      ),
      body: projects.isEmpty
          ? const Center(child: Text('No projects found.'))
          : ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final projectDir = projects[index];
          final videoFile = File('${projectDir.path}/video.mp4');
          final framesDir = Directory('${projectDir.path}/frames');

          return Card(
            child: ListTile(
              title: Text('Project ${projectDir.path.split('/').last}'),
              subtitle: const Text('Contains video and frames'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailsPage(
                      videoPath: videoFile.path,
                      framesDirPath: framesDir.existsSync() ? framesDir.path : null,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProjectDetailsPage extends StatelessWidget {
  final String videoPath;
  final String? framesDirPath;

  const ProjectDetailsPage({super.key, required this.videoPath, this.framesDirPath});

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
          if (framesDirPath != null)
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('View Frames'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FramesGalleryPage(framesDirPath: framesDirPath!),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
