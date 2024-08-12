import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_video_app/project_gallery_page.dart'; // Importar a nova página da galeria de projetos

class CameraPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const CameraPage({super.key, required this.onThemeChanged});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final log = Logger();
  bool _isLoading = true;
  late CameraController _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  double _zoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  final double _exposureOffset = 0.0;
  double _minExposureOffset = 0.0;
  double _maxExposureOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final backCamera = _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: true,
      );

      await _cameraController.initialize();

      // Obter os níveis de zoom e exposição
      _minZoomLevel = await _cameraController.getMinZoomLevel();
      _maxZoomLevel = await _cameraController.getMaxZoomLevel();
      _minExposureOffset = await _cameraController.getMinExposureOffset();
      _maxExposureOffset = await _cameraController.getMaxExposureOffset();



      setState(() => _isLoading = false);
    } catch (e) {
      log.e("Error initializing camera: $e");
      developer.log('Error initializing camera: $e', name: 'CameraPage');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _captureVideo() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String projectDirName = DateTime.now().millisecondsSinceEpoch.toString();
      Directory projectDir = Directory('${appDocDir.path}/$projectDirName');
      await projectDir.create(recursive: true);

      if (_isRecording) {
        XFile videoFile = await _cameraController.stopVideoRecording();
        setState(() => _isRecording = false);

        File newVideo = await File(videoFile.path).copy('${projectDir.path}/video.mp4');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video recorded successfully!')),
        );

      } else {
        await _cameraController.startVideoRecording();
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

  // Navegar para a galeria de projetos
  void _openGallery() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectGalleryPage(baseDir: appDocDir), // Passar o diretório base para a galeria
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
              icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
              tooltip: 'Record Video',
              onPressed: _captureVideo,
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
              child: CameraPreview(_cameraController),
            ),
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  onPressed: _captureVideo,
                  child: Icon(_isRecording ? Icons.stop : Icons.circle),
                ),
              ),
            ),
            Slider(
              value: _zoomLevel,
              min: _minZoomLevel,
              max: _maxZoomLevel,
              onChanged: (value) {
                setState(() {
                  _zoomLevel = value;
                  _cameraController.setZoomLevel(value);
                });
              },
            ),
          ],
        ),
      );
    }
  }
}
