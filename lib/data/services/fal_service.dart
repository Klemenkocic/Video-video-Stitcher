import 'package:supabase_flutter/supabase_flutter.dart';

class FalService {
  /// Submits a video generation request to the backend.
  Future<String> generateVideo({
    required String imageUrl,
    required String tailImageUrl,
    required String prompt,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'generate-video', // Edge Function
        body: {
          'action': 'generate',
          'prompt': prompt,
          'imageUrl': imageUrl,
          'tailImageUrl': tailImageUrl, // Matches JSON key in Edge Function
        },
      );

      final data = response.data;
      if (data['error'] != null) throw Exception(data['error']);

      final requestId = data['request_id'];
      if (requestId == null) throw Exception('No request ID returned from backend');
      
      return requestId;
    } catch (e) {
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
          'generate-video',
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
         print('Polling transient error: $e'); // Don't crash immediately on network blip
      }
      
      attempts++;
    }
    throw Exception('Video generation timed out');
  }
}
