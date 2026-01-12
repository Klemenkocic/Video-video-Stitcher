import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../widgets/navigation/app_fab.dart';
import '../../widgets/project/timeline_view.dart';
import '../../providers/project_provider.dart';

/// Default prompt for text nodes
const String _defaultTextPrompt = '''Cinematic drone flyover transition. Smooth aerial camera movement flying from the first location to the second location. Flying forward motion, gentle altitude changes, natural lighting, travel documentary style, seamless transition between the two scenes.''';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectNotifierProvider);
    final config = ref.watch(appConfigProvider);
    final hasNodes = project.nodes.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            hasNodes
                ? TimelineView(project: project)
                : const _EmptyState(),

            // Dev Mode Indicator (top-right badge)
            if (kDebugMode && !config.isProduction)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.sunsetGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        config.environment.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        config.environment.displayName.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.charcoal,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: AppFab(
        onAddImage: () {
          // Add empty image node - user will tap to add image
          ref.read(projectNotifierProvider.notifier).addImageNode('');
        },
        onAddText: () {
          // Add text node with default prompt
          ref.read(projectNotifierProvider.notifier).addTextNode(_defaultTextPrompt);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              Icons.add_photo_alternate_rounded, 
              size: 80,
              color: AppTheme.greyMedium.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Start your journey',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap + to add your first memory',
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

