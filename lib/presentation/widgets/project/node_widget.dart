import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/node_model.dart';

class NodeWidget extends StatelessWidget {
  final ProjectNode node;
  final bool isLast;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const NodeWidget({
    super.key,
    required this.node,
    this.isLast = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = node.type == NodeType.image
        ? _ImageNodeCard(node: node)
        : _TextNodeCard(node: node);
    
    // Wrap in GestureDetector for tap-to-edit
    final tappableCard = GestureDetector(
      onTap: onTap,
      child: cardWidget,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _StepNumber(index: node.order),
                if (!isLast)
                   Expanded(
                    child: Container(
                      width: 1,
                      color: AppTheme.greyMedium.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Content Card (Dismissible + Tappable)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: onDelete != null
                  ? Dismissible(
                      key: Key(node.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => onDelete?.call(),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      ),
                      child: tappableCard,
                    )
                  : tappableCard,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNumber extends StatelessWidget {
  final int index;

  const _StepNumber({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark, // Dark circle
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          color: AppTheme.greyMedium, // Muted numbering
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ImageNodeCard extends StatelessWidget {
  final ProjectNode node;

  const _ImageNodeCard({required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24), // Squircle
        // No shadow, flat design
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (node.content.startsWith('http'))
             CachedNetworkImage(
              imageUrl: node.content,
              fit: BoxFit.cover,
               placeholder: (context, url) => const Center(
                 child: SizedBox(
                   width: 20, height: 20, 
                   child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white)
                 )
               ),
               errorWidget: (context, url, error) => const Icon(Icons.error, color: AppTheme.greyMedium),
             )
          else if (node.content.isNotEmpty)
              Image.file(
                File(node.content),
                fit: BoxFit.cover,
              )
          else
             const Center(
               child: Icon(Icons.add_photo_alternate_rounded, color: AppTheme.greyMedium, size: 32),
             ),
             
          // Minimal Badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.image, color: AppTheme.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextNodeCard extends StatelessWidget {
  final ProjectNode node;

  const _TextNodeCard({required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24), // Squircle
        // No border, just surface contrast
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROMPT',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greyMedium,
                ),
              ),
              const Icon(Icons.text_fields, color: AppTheme.greyMedium, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            node.content.isEmpty ? 'Describe the transition...' : node.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: node.content.isEmpty ? AppTheme.greyMedium : AppTheme.white,
              height: 1.4,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
