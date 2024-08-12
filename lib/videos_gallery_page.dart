import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'frames_gallery_page.dart';

class VideoGalleryPage extends StatefulWidget {
  const VideoGalleryPage({super.key});

  @override
  _VideoGalleryPageState createState() => _VideoGalleryPageState();
}

class _VideoGalleryPageState extends State<VideoGalleryPage> {
  late List<FileSystemEntity> _videoFiles;

  @override
  void initState() {
    super.initState();
    _loadVideoFiles();
  }

  Future<void> _loadVideoFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _videoFiles = directory.listSync().where((file) => file.path.endsWith('.mp4')).toList();
    });
  }

  void _deleteVideo(String path) {
    File(path).deleteSync();
    _loadVideoFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorded Videos'),
      ),
      body: _videoFiles.isEmpty
          ? const Center(child: Text('No videos found.'))
          : ListView.builder(
        itemCount: _videoFiles.length,
        itemBuilder: (context, index) {
          final videoFile = _videoFiles[index];
          return ListTile(
            title: Text(videoFile.path.split('/').last),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(videoPath: videoFile.path),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteVideo(videoFile.path),
            ),
          );
        },
      ),
    );
  }
}



class VideoPlayerPage extends StatefulWidget {
  final String videoPath;

  const VideoPlayerPage({super.key, required this.videoPath});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isProcessing = false;
  String? _framesDirPath;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _convertVideoToFrames() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Obter o diretório para salvar os frames
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _framesDirPath = '${appDocDir.path}/frames_${widget.videoPath.split('/').last.split('.').first}';
      await Directory(_framesDirPath!).create(recursive: true);

      // Comando para converter vídeo em frames
      String command = '-i ${widget.videoPath} $_framesDirPath/frame_%04d.jpg';

      // Executar comando FFmpeg
      await FFmpegKit.execute(command);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Frames saved to $_framesDirPath')),
      );

      // Navegar para a galeria de frames
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FramesGalleryPage(framesDirPath: _framesDirPath!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error converting video to frames.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _controller.value.isPlaying ? _controller.pause : _controller.play,
            child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(height: 16), // Espaço entre os botões
          FloatingActionButton(
            onPressed: _isProcessing ? null : _convertVideoToFrames,
            child: _isProcessing
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
