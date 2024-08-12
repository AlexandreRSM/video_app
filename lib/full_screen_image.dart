import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  final ThemeMode themeMode;

  const FullScreenImage({super.key, required this.imagePath, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isImageValid(imagePath), // Chama a função de validação da imagem
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostra um indicador de progresso enquanto a imagem está sendo validada
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.data!) {
          // Mostra uma mensagem de erro se a imagem não for válida
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: const Center(
              child: Text('Invalid or corrupted image file.'),
            ),
          );
        } else {
          // Se a imagem for válida, exibe a interface normal
          return MaterialApp(
            themeMode: themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Center(
                    child: Image.file(File(imagePath)), // Exibe a imagem em tela cheia
                  ),
                  Positioned(
                    top: 40.0,
                    right: 20.0,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      tooltip: 'Edit Image',
                      onPressed: () {
                        _editImage(context, imagePath);
                      },
                    ),
                  ),
                  Positioned(
                    top: 40.0,
                    left: 20.0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      tooltip: 'Back',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<bool> isImageValid(String imagePath) async {
    try {
      // Verifica se o arquivo existe
      final file = File(imagePath);
      if (!file.existsSync()) {
        return false;
      }

      // Tenta carregar a imagem usando ImageProvider
      final bytes = file.readAsBytesSync();
      final image = MemoryImage(Uint8List.fromList(bytes));

      // Tenta carregar a imagem para verificar se ela é válida
      final completer = Completer<void>();
      image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
              (ImageInfo info, bool _) => completer.complete(),
          onError: (dynamic error, StackTrace? stackTrace) {
            completer.completeError(error, stackTrace);
          },
        ),
      );
      await completer.future;
      return true;
    } catch (e) {
      developer.log(
        'Error validating image',
        name: 'FullScreenImage',
        error: e,
        stackTrace: StackTrace.current,
      );
      return false;
    }
  }

  Future<void> _editImage(BuildContext context, String imagePath) async {
    try {
      final Uint8List? editedImage = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: File(imagePath),
          ),
        ),
      );

      if (editedImage != null && editedImage.isNotEmpty) {
        final file = File(imagePath);
        file.writeAsBytesSync(editedImage); // Salva o Uint8List diretamente no arquivo

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image edited successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid image data.')),
        );
      }
    } catch (e) {
      developer.log(
        'Error editing image',
        name: 'FullScreenImage',
        error: e,
        stackTrace: StackTrace.current,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error editing image.')),
      );
    }
  }
}
