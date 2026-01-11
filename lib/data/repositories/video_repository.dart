import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/fal_service.dart';

part 'video_repository.g.dart';

class VideoRepository {
  final FalService _falService;

  VideoRepository(this._falService);

  Future<String> generateTransition({
    required String firstImagePath,
    required String secondImagePath,
    required String prompt,
  }) async {
    // Images should already be uploaded to Supabase storage or Fal storage
    // and passed as URLs (not file paths)

    // Submit generation job
    final requestId = await _falService.generateVideo(
      imageUrl: firstImagePath,  // Expected to be a URL
      tailImageUrl: secondImagePath,  // Expected to be a URL
      prompt: prompt,
    );

    // Poll for result
    return await _falService.pollStatus(requestId);
  }
}

@riverpod
VideoRepository videoRepository(VideoRepositoryRef ref) {
  return VideoRepository(FalService());
}
