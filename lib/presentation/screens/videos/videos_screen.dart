import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../providers/video_library_provider.dart';
import '../../../data/services/download_service.dart';

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videoLibraryProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        bottom: false,
        child: videosAsync.when(
          data: (videos) => videos.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _VideoCard(video: video);
                  },
                ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.white),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error loading videos: $error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: AppTheme.greyMedium.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No videos yet',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Generate your first video from the Dashboard',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends ConsumerStatefulWidget {
  final VideoItem video;

  const _VideoCard({required this.video});

  @override
  ConsumerState<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends ConsumerState<_VideoCard> {
  bool _isDownloading = false;

  Future<void> _downloadAndShare() async {
    setState(() => _isDownloading = true);
    
    try {
      final downloadService = ref.read(downloadServiceProvider);
      
      // Download
      final filePath = await downloadService.downloadVideo(widget.video.url);
      
      // Share
      await downloadService.shareFile(
        filePath, 
        text: 'My Traverse travel video: ${widget.video.title}',
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: widget.video.thumbnailUrl != null
                  ? Image.network( // Changed to Image.network since URLs are from DB
                      widget.video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderThumbnail(),
                    )
                  : _placeholderThumbnail(),
            ),
          ),
          
          // Info Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(widget.video.createdAt),
                        style: const TextStyle(
                          color: AppTheme.greyMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Download Button
                GestureDetector(
                  onTap: _isDownloading ? null : _downloadAndShare,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.black,
                            ),
                          )
                        : const Icon(
                            Icons.download_rounded,
                            color: AppTheme.black,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderThumbnail() {
    return Container(
      color: AppTheme.surfaceLight,
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: AppTheme.greyMedium, size: 48),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
