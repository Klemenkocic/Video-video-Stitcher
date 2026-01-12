import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'download_service.g.dart';

@riverpod
DownloadService downloadService(DownloadServiceRef ref) {
  return DownloadService(Dio());
}

class DownloadService {
  final Dio _dio;

  DownloadService(this._dio);

  Future<String> downloadVideo(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'traverse_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${tempDir.path}/$fileName';
      
      await _dio.download(url, filePath);
      return filePath;
    } catch (e) {
      throw Exception('Failed to download video: $e');
    }
  }

  Future<void> shareFile(String filePath, {String? text}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found at $filePath');
    }
    
    await Share.shareXFiles(
      [XFile(filePath)],
      text: text,
    );
  }
}
