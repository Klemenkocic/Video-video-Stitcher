import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_library_provider.g.dart';

class VideoItem {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final String title;
  final DateTime createdAt;

  VideoItem({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    required this.title,
    required this.createdAt,
  });
}

@riverpod
class VideoLibrary extends _$VideoLibrary {
  @override
  List<VideoItem> build() {
    return [];
  }

  void addVideo(String url, {String? thumbnailUrl, String? title}) {
    final video = VideoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      thumbnailUrl: thumbnailUrl,
      title: title ?? 'Travel Video ${state.length + 1}',
      createdAt: DateTime.now(),
    );
    state = [video, ...state]; // Add to beginning
  }

  void removeVideo(String id) {
    state = state.where((v) => v.id != id).toList();
  }
}
