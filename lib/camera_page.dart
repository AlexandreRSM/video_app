import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_video_app/video_page.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_video_app/project_gallery_page.dart';


class CameraPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const CameraPage({super.key, required this.onThemeChanged});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final log = Logger();
  bool _isLoading = true;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  double _zoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  bool _isSlowMotion = false;
  Directory? _currentProjectDir;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera({bool slowMotion = false}) async {
    try {
      if (_cameraController != null) {
        await _cameraController?.dispose();
      }

      _cameras = await availableCameras();
      final backCamera = _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraController = CameraController(
        backCamera,
        slowMotion ? ResolutionPreset.high : ResolutionPreset.max,
        enableAudio: true,
      );

      await _cameraController?.initialize();

      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      log.e("Error initializing camera: $e");
      developer.log('Error initializing camera: $e', name: 'CameraPage');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.isEmpty || _cameraController == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _cameraController?.dispose();

      CameraDescription newCamera = _cameraController!.description.lensDirection == CameraLensDirection.back
          ? _cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front)
          : _cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);

      _cameraController = CameraController(newCamera, ResolutionPreset.max, enableAudio: true);

      await _cameraController!.initialize();

      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      developer.log('Error switching camera: $e', name: 'CameraPage');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching camera: $e')),
        );
      }
    }
  }

  Future<void> _captureVideo() async {
    try {
      if (_isRecording && _cameraController != null) {
        XFile videoFile = await _cameraController!.stopVideoRecording();
        setState(() => _isRecording = false);

        if (_currentProjectDir != null) {
          File newVideo = await File(videoFile.path).copy('${_currentProjectDir!.path}/video.mp4');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video recorded successfully at ${newVideo.path}!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerPage(videoPath: newVideo.path),
            ),
          );
        }
      } else if (_cameraController != null) {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String projectDirName = DateTime.now().millisecondsSinceEpoch.toString();
        _currentProjectDir = Directory('${appDocDir.path}/$projectDirName');

        await _currentProjectDir!.create(recursive: true);

        await _cameraController!.startVideoRecording();
        setState(() => _isRecording = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording video...')),
        );
      }
    } catch (e) {
      developer.log('Error capturing video: $e', name: 'CameraPage');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing video.')),
      );
    }
  }

  void _toggleSlowMotion() {
    setState(() {
      _isSlowMotion = !_isSlowMotion;
      _initCamera(slowMotion: _isSlowMotion);
    });
  }

  void _openGallery() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectGalleryPage(baseDir: appDocDir),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 60.0,
          actions: [
            IconButton(
              icon: Icon(_isSlowMotion ? Icons.slow_motion_video : Icons.slow_motion_video_rounded),
              onPressed: _toggleSlowMotion,
            ),
            IconButton(
              icon: const Icon(Icons.switch_camera),
              tooltip: 'Switch Camera',
              onPressed: _switchCamera,
            ),
            IconButton(
              icon: const Icon(Icons.video_library),
              tooltip: 'Open Project Gallery',
              onPressed: _openGallery,
            ),
            PopupMenuButton<ThemeMode>(
              onSelected: (ThemeMode mode) {
                widget.onThemeChanged(mode);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Mode'),
                ),
                const PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Mode'),
                ),
                const PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Mode'),
                ),
              ],
              icon: const Icon(Icons.brightness_6),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: _cameraController != null && _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.blue,
                    onPressed: _captureVideo,
                    child: Icon(_isRecording ? Icons.stop : Icons.circle),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _zoomLevel,
                    min: _minZoomLevel,
                    max: _maxZoomLevel,
                    onChanged: _cameraController != null
                        ? (value) {
                      setState(() {
                        _zoomLevel = value;
                        _cameraController!.setZoomLevel(value);
                      });
                    }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
