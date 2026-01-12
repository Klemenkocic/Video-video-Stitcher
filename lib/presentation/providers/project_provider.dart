import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/project_model.dart';
import '../../data/models/node_model.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/services/billing_service.dart';
import '../../core/config/billing_constants.dart';
import 'video_library_provider.dart';

part 'project_provider.g.dart';

@riverpod
class ProjectNotifier extends _$ProjectNotifier {
  @override
  Project build() {
    return Project.create();
  }

  Future<void> generateVideo() async {
    if (!isValidSequence) return;

    // Check and deduct credits via billing service
    // In dev mode, this will bypass credit checks
    final billingService = ref.read(billingServiceProvider);
    final hasSufficientCredits = await billingService.deductCredits(
      BillingConstants.videoGenerationCost,
      'Video Generation: ${state.title}',
    );

    if (!hasSufficientCredits) {
      developer.log(
        'Insufficient credits for video generation',
        name: 'ProjectProvider',
      );
      state = state.copyWith(status: ProjectStatus.insufficientCredits);
      return;
    }

    // Update status to generating
    state = state.copyWith(status: ProjectStatus.generating);

    try {
      final repo = ref.read(videoRepositoryProvider);

      // Extract data from nodes
      final startNode = state.nodes[0];
      final textNode = state.nodes[1];
      final endNode = state.nodes[2];

      developer.log(
        'Starting video generation with Fal API',
        name: 'ProjectProvider',
      );

      final videoUrl = await repo.generateTransition(
        firstImageUrl: startNode.content,
        secondImageUrl: endNode.content,
        prompt: textNode.content,
      );

      developer.log(
        'Video generation completed: $videoUrl',
        name: 'ProjectProvider',
      );

      // Refresh video library to show new video
      ref.invalidate(videoLibraryProvider);

      // Success
      state = state.copyWith(
        status: ProjectStatus.completed,
        videoUrl: videoUrl,
        videoThumbnailUrl: startNode.content,
      );
    } catch (e, stack) {
      developer.log(
        'Video generation failed',
        error: e,
        stackTrace: stack,
        name: 'ProjectProvider',
      );
      state = state.copyWith(status: ProjectStatus.failed);
    }
  }

  void addImageNode(String path) {
    _addNode(NodeType.image, path);
  }

  void addTextNode(String text) {
    _addNode(NodeType.text, text);
  }

  void _addNode(NodeType type, String content) {
    final newNodes = List<ProjectNode>.from(state.nodes);
    newNodes.add(ProjectNode.create(
      type: type,
      content: content,
      order: newNodes.length,
    ));

    state = state.copyWith(nodes: newNodes);
  }

  void removeNode(String nodeId) {
    final newNodes = state.nodes.where((n) => n.id != nodeId).toList();
    state = state.copyWith(nodes: newNodes);
  }

  void updateNodeContent(String nodeId, String newContent) {
    final newNodes = state.nodes.map((n) {
      if (n.id == nodeId) {
        return ProjectNode(
          id: n.id,
          type: n.type,
          content: newContent,
          order: n.order,
        );
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: newNodes);
  }

  bool get isValidSequence {
    // Valid: Image -> Text -> Image
    if (state.nodes.length != 3) return false;
    if (state.nodes[0].type != NodeType.image) return false;
    if (state.nodes[1].type != NodeType.text) return false;
    if (state.nodes[2].type != NodeType.image) return false;
    return true;
  }
}
