import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'dart:developer' as developer;
import 'dart:io';

class EditVideoPage {
  static Future<bool> convertVideoToFrame(String filePath) async {
    bool success = false;

    var tokens = filePath.split('/');
    var path = tokens.getRange(0, tokens.length - 1).join('/');
    var fileName = tokens[tokens.length - 1].split('.')[0];
    String dir = '$path/$fileName';

    await Directory(dir).create(recursive: true);

    var session = await FFmpegKit.execute('-i $filePath $dir/frame%d.jpg');
    var logs = await session.getAllLogsAsString();
    developer.log('----> $logs');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      success = true;
    }

    return success;
  }

  static Future<bool> convertFrameToVideo(String dirPath, String outputPath) async {
    bool success = false;

    var dir = Directory(dirPath);
    if (!await dir.exists()) {
      developer.log('Directory $dirPath does not exist.');
      return success;
    }

    var files = dir.listSync().where((file) => file.path.endsWith('.jpg')).toList();
    if (files.isEmpty) {
      developer.log('No JPEG files found in $dirPath.');
      return success;
    }

    String command = '-framerate 30 -i $dirPath/frame%d.jpg -c:v mpeg4 -pix_fmt yuv420p $outputPath';
    developer.log('Executing FFmpeg command: $command');

    var session = await FFmpegKit.execute(command);
    var logs = await session.getAllLogsAsString();
    developer.log('Logs from convertFrameToVideo: $logs');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      success = true;
      developer.log('Video created successfully at $outputPath');
    } else {
      developer.log('Error creating video. Return code: $returnCode');
    }

    return success;
  }

  static Future<void> removeAudioFromVideo(String inputPath, String dirPath) async {
    await Directory(dirPath).create(recursive: true);

    String outputPath = '$dirPath/audio.aac';
    String command = '-i $inputPath -vn -acodec aac $outputPath';
    developer.log('Executing FFmpeg command: $command');

    var session = await FFmpegKit.execute(command);
    var logs = await session.getAllLogsAsString();
    developer.log('Logs from removeAudioFromVideo: $logs');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      developer.log('Audio extracted and converted to AAC successfully at $outputPath');
    } else {
      developer.log('Error extracting and converting audio. Return code: $returnCode');
    }
  }

  static Future<void> convertAudioToMp3(String inputPath, String dirPath) async {
    await Directory(dirPath).create(recursive: true);

    String outputPath = '$dirPath/audio.mp3';
    String command = '-i $inputPath -acodec libmp3lame $outputPath';

    var session = await FFmpegKit.execute(command);
    var returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      developer.log('Audio converted to MP3 successfully at $outputPath');
    } else {
      developer.log('Error converting audio to MP3 with libmp3lame. Return code: $returnCode');
    }

    var logs = await session.getAllLogsAsString();
    developer.log('Logs from convertAudioToMp3: $logs');
  }

  Future<void> addAudioToVideo() async {}
}
