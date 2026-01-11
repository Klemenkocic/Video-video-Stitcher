import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback
import '../../../core/theme/app_theme.dart';

class AppFab extends StatelessWidget {
  final VoidCallback? onAddImage;
  final VoidCallback? onAddText;

  const AppFab({
    super.key,
    this.onAddImage,
    this.onAddText,
  });

  void _showAddMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _AddNodePopup(
        onImageTap: () {
          Navigator.pop(context);
          onAddImage?.call();
        },
        onTextTap: () {
          Navigator.pop(context);
          onAddText?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddMenu(context),
      backgroundColor: AppTheme.white,
      elevation: 0,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: AppTheme.black, size: 32),
    );
  }
}

/// Custom right-aligned popup (half-height, right side)
class _AddNodePopup extends StatelessWidget {
  final VoidCallback onImageTap;
  final VoidCallback onTextTap;

  const _AddNodePopup({required this.onImageTap, required this.onTextTap});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16, bottom: 100), // Above nav bar
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _PopupOptionTile(
              icon: Icons.image_outlined,
              label: 'Image',
              onTap: onImageTap,
            ),
            const SizedBox(height: 12),
            _PopupOptionTile(
              icon: Icons.text_fields,
              label: 'Text',
              onTap: onTextTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PopupOptionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.white, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
