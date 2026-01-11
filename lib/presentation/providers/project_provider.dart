import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/project_model.dart';
import '../../data/models/node_model.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/credit_repository.dart';
import '../../core/constants/app_constants.dart';
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

    // Check credits first
    final creditRepo = ref.read(creditRepositoryProvider);
    final hasSufficentCredits = await creditRepo.deductCredits(
      AppConstants.simpleVideoCost,
      'Video Generation: ${state.title}',
    );

    if (!hasSufficentCredits) {
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

      final videoUrl = await repo.generateTransition(
        firstImagePath: startNode.content,
        secondImagePath: endNode.content,
        prompt: textNode.content,
      );

      // Save to video library
      ref.read(videoLibraryProvider.notifier).addVideo(
        videoUrl,
        thumbnailUrl: startNode.content,
        title: 'Travel Video',
      );

      // Success
      state = state.copyWith(
        status: ProjectStatus.completed,
        videoUrl: videoUrl,
        videoThumbnailUrl: startNode.content, 
      );
    } catch (e) {
      state = state.copyWith(status: ProjectStatus.failed);
      print('Generation Error: $e');
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
