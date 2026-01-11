import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/node_model.dart';
import '../../../data/services/media_service.dart';
import '../../providers/project_provider.dart';
import '../../widgets/project/video_player_widget.dart';
import '../../widgets/dialogs/text_input_dialog.dart';
import 'node_widget.dart';
import '../../../core/theme/app_theme.dart';

class TimelineView extends ConsumerWidget {
  final Project project;

  const TimelineView({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(projectNotifierProvider.notifier);
    final isGenerating = project.status == ProjectStatus.generating;
    
    // Validation: Image -> Text -> Image with non-empty content
    final isValid = project.nodes.length == 3 && 
                    project.nodes[0].type == NodeType.image && 
                    project.nodes[0].content.isNotEmpty &&
                    project.nodes[1].type == NodeType.text &&
                    project.nodes[2].type == NodeType.image &&
                    project.nodes[2].content.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
      children: [
        // Video Result (Top)
        if (project.videoUrl != null) ...[
           VideoResultPlayer(videoUrl: project.videoUrl!),
           const SizedBox(height: 24),
           Divider(color: AppTheme.greyMedium.withOpacity(0.3)),
           const SizedBox(height: 24),
        ],

        // Nodes (with delete + tap-to-edit)
        ...List.generate(project.nodes.length, (index) {
          final node = project.nodes[index];
          final isLast = index == project.nodes.length - 1;
          return NodeWidget(
            node: node, 
            isLast: isLast, 
            onDelete: () => notifier.removeNode(node.id),
            onTap: () => _handleNodeTap(context, ref, node),
          );
        }),

        const SizedBox(height: 32),

        // Generate Button
        if (isValid && project.status != ProjectStatus.completed) 
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isGenerating ? null : () => notifier.generateVideo(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                disabledBackgroundColor: AppTheme.surfaceDark,
                foregroundColor: AppTheme.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.greyMedium)
                        ),
                        const SizedBox(width: 12),
                        Text('Generating...', style: TextStyle(color: AppTheme.greyMedium)),
                      ],
                    )
                  : const Text(
                      'Generate Video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
        if (project.status == ProjectStatus.failed)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Generation failed. Please try again.',
                style: TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
            
        // Branded Insufficient Credits Message
        if (project.status == ProjectStatus.insufficientCredits)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: AppTheme.greyMedium, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Insufficient credits',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Top up your credits to generate videos',
                    style: TextStyle(color: AppTheme.greyMedium, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Future<void> _handleNodeTap(BuildContext context, WidgetRef ref, ProjectNode node) async {
    final notifier = ref.read(projectNotifierProvider.notifier);
    
    if (node.type == NodeType.image) {
      // Open image picker
      final picker = MediaService();
      final path = await picker.pickImage(source: ImageSource.gallery);
      if (path != null) {
        final cropped = await picker.cropImage(path: path);
        if (cropped != null) {
          notifier.updateNodeContent(node.id, cropped);
        }
      }
    } else if (node.type == NodeType.text) {
      // Open text editor with current content
      final newText = await showDialog<String>(
        context: context,
        builder: (context) => TextInputDialog(initialText: node.content),
      );
      if (newText != null && newText.isNotEmpty) {
        notifier.updateNodeContent(node.id, newText);
      }
    }
  }
}

