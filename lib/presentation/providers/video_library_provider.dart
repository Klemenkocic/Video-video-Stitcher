import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'],
      url: json['video_url'] ?? '',
      thumbnailUrl: json['video_thumbnail_url'],
      title: json['title'] ?? 'Untitled',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

@riverpod
class VideoLibrary extends _$VideoLibrary {
  @override
  FutureOr<List<VideoItem>> build() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    
    if (userId == null) return [];

    final response = await client
        .from('projects')
        .select()
        .eq('user_id', userId)
        .eq('status', 'completed') // Only completed videos
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    return data.map((json) => VideoItem.fromJson(json)).toList();
  }
}
