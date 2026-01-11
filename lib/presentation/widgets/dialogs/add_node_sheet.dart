import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AddNodeSheet extends StatelessWidget {
  final VoidCallback onImageTap;
  final VoidCallback onTextTap;

  const AddNodeSheet({
    super.key,
    required this.onImageTap,
    required this.onTextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark, // Monochrome
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add to Project',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _OptionCard(
                icon: Icons.image_outlined,
                label: 'Image',
                onTap: () {
                  Navigator.pop(context);
                  onImageTap();
                },
              ),
              const SizedBox(width: 16),
              _OptionCard(
                icon: Icons.text_fields,
                label: 'Text',
                onTap: () {
                  Navigator.pop(context);
                  onTextTap();
                },
              ),
              const SizedBox(width: 16),
               const _OptionCard(
                icon: Icons.videocam_outlined,
                label: 'Video',
                onTap: null,
                isDisabled: true,
              ),
            ],
          ),
           const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDisabled ? AppTheme.black.withOpacity(0.3) : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDisabled ? AppTheme.greyMedium.withOpacity(0.5) : AppTheme.white,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: isDisabled ? AppTheme.greyMedium.withOpacity(0.5) : AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isDisabled)
                Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(
                     'Soon',
                     style: TextStyle(
                       fontSize: 10,
                       color: AppTheme.greyMedium.withOpacity(0.5),
                     ),
                   ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
