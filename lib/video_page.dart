import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_video_app/ffmpeg_works.dart';
import 'package:flutter_video_app/frames_gallery_page.dart';

class VideoPage extends StatefulWidget {
  final String filePath;

  const VideoPage({super.key, required this.filePath});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  bool _isProcessing = false;

  get framesDirPath => null;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
    setState(() {});
  }

  Future<void> _convertToFrames() async {
    setState(() => _isProcessing = true);

    var result = await EditVideoPage.convertVideoToFrame(widget.filePath);
    setState(() => _isProcessing = false);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video converted to frames successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FramesGalleryPage(framesDirPath: framesDirPath)
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to convert video to frames')),
      );
    }
  }

  Future<void> _convertFramesToVideo() async {
    setState(() => _isProcessing = true);

    var tokens = widget.filePath.split('/');
    var path = tokens.getRange(0, tokens.length - 1).join('/');
    var fileName = tokens[tokens.length - 1].split('.')[0];
    String dir = '$path/$fileName';
    String outputVideoPath = '$path/${fileName}_rebuilt.mp4';

    var result = await EditVideoPage.convertFrameToVideo(dir, outputVideoPath);
    setState(() => _isProcessing = false);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Frames converted to video successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to convert frames to video')),
      );
    }
  }

  Future<void> _removeAudio() async {
    setState(() => _isProcessing = true);

    var tokens = widget.filePath.split('/');
    var path = tokens.getRange(0, tokens.length - 1).join('/');
    var fileName = tokens[tokens.length - 1].split('.')[0];
    String dir = '$path/$fileName';

    await EditVideoPage.removeAudioFromVideo(widget.filePath, dir);
    await EditVideoPage.convertAudioToMp3('$dir/audio.aac', dir);

    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio extracted as .aac')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Preview'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _isProcessing ? null : _convertToFrames,
            tooltip: 'Convert to Frames',
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            onPressed: _isProcessing ? null : _removeAudio,
            tooltip: 'Remove Audio',
          ),
          IconButton(
            icon: const Icon(Icons.video_camera_back),
            onPressed: _isProcessing ? null : _convertFramesToVideo,
            tooltip: 'Convert Frames to Video',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: _videoPlayerController.value.isInitialized
          ? Stack(
        children: [
          VideoPlayer(_videoPlayerController),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
