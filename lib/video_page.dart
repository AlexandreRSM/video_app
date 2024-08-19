import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:developer' as developer;

class VideoPlayerPage extends StatefulWidget {
  final String videoPath;

  const VideoPlayerPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      // Verifica se o arquivo de vídeo existe
      if (await File(widget.videoPath).exists()) {
        _controller = VideoPlayerController.file(File(widget.videoPath));

        await _controller!.initialize().then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          _controller!.play(); // Inicia a reprodução do vídeo automaticamente
        });
      } else {
        developer.log('Video file does not exist at path: ${widget.videoPath}', name: 'VideoPlayerPage');
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      developer.log('Error initializing video player: $e', name: 'VideoPlayerPage');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Certifique-se de que o controlador seja descartado corretamente
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: const Text('Failed to load video'))
          : _controller != null && _controller!.value.isInitialized
          ? AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      )
          : const Text('Failed to initialize video controller.'),
      floatingActionButton: _controller != null && _controller!.value.isInitialized
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      )
          : null,
    );
  }
}
