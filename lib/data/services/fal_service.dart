import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';

part 'fal_service.g.dart';

@riverpod
FalService falService(FalServiceRef ref) {
  return FalService();
}

class FalService {
  /// Submits a video generation request to the backend.
  Future<String> generateVideo({
    required String imageUrl,
    required String tailImageUrl,
    required String prompt,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        AppConstants.functionGenerateVideo,
        body: {
          'action': 'generate',
          'prompt': prompt,
          'imageUrl': imageUrl,
          'tailImageUrl': tailImageUrl,
        },
      );

      final data = response.data;
      if (data['error'] != null) throw Exception(data['error']);

      final requestId = data['request_id'];
      if (requestId == null) throw Exception('No request ID returned from backend');
      
      return requestId;
    } catch (e) {
      developer.log('Video Generation Error', error: e, name: 'FalService');
      throw Exception('Video Generation Error: $e');
    }
  }

  /// Polls the status via backend.
  Future<String> pollStatus(String requestId) async {
    int attempts = 0;
    while (attempts < 60) { 
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        final response = await Supabase.instance.client.functions.invoke(
          AppConstants.functionGenerateVideo,
          body: {
            'action': 'check_status',
            'requestId': requestId,
          },
        );

        final data = response.data;
        if (data['error'] != null) throw Exception(data['error']);

        final status = data['status']; // 'IN_QUEUE', 'IN_PROGRESS', 'COMPLETED', 'FAILED'
        
        if (status == 'COMPLETED') {
           final videoUrl = data['video']['url'];
           return videoUrl;
        } else if (status == 'FAILED') {
          throw Exception('Video generation failed: ${data['error']}');
        }
      } catch (e) {
         developer.log('Polling transient error', error: e, name: 'FalService');
      }
      
      attempts++;
    }
    throw Exception('Video generation timed out');
  }
}
