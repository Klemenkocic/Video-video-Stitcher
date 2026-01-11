import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// A minimalist onboarding screen.
/// The "interactive onboarding" happens ON the Dashboard by pre-populating nodes.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Text(
                'Traverse',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cinematic travel memories',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              
              // Illustrations / Features
              _FeatureItem(
                icon: Icons.image,
                title: '1. Add Photos',
                description: 'Start and end points of your journey.',
              ),
              const SizedBox(height: 16),
              _FeatureItem(
                icon: Icons.text_fields,
                title: '2. Describe',
                description: 'Tell AI how to create the transition.',
              ),
              const SizedBox(height: 16),
              _FeatureItem(
                icon: Icons.play_circle_fill,
                title: '3. Generate',
                description: 'Watch your cinematic video come to life.',
              ),
              const Spacer(),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: AppTheme.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
