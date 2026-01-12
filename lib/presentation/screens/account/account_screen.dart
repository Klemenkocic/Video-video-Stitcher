import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/billing_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/credit_repository.dart';
import '../../../data/services/billing_service.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final creditsAsync = ref.watch(userCreditsProvider);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dev Mode Banner (only in debug builds when not in production)
              if (kDebugMode && !config.isProduction) ...[
                _DevModeBanner(config: config),
                const SizedBox(height: 16),
              ],

              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.surfaceDark,
                    child: Text(
                      user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? 'Traveler',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Free Plan',
                          style: TextStyle(color: AppTheme.greyMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Credit Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'CREDITS',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.greyMedium,
                              ),
                        ),
                        if (!config.enableCreditSystem) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.sunsetGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'UNLIMITED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.charcoal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    creditsAsync.when(
                      data: (credits) => Text(
                        config.enableCreditSystem ? '$credits' : '∞',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.white,
                        ),
                      ),
                      error: (_, __) => const Text(
                        'Error',
                        style: TextStyle(color: AppTheme.greyMedium),
                      ),
                    ),
                    if (!config.enableCreditSystem) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${config.environment.emoji} Dev Mode: Credits Disabled',
                        style: const TextStyle(
                          color: AppTheme.sunsetGold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Top Up Options (only if credit system enabled)
              if (config.enableCreditSystem) ...[
                Text(
                  'Top Up',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.white,
                      ),
                ),
                const SizedBox(height: 16),
                ...BillingConstants.allPackages.map((package) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CreditOptionCard(
                      package: package,
                      onTap: () => _purchaseCredits(context, ref, package),
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ] else ...[
                // Dev mode: Manual credit addition button
                if (kDebugMode) ...[
                  _DevCreditControls(ref: ref),
                  const SizedBox(height: 32),
                ],
              ],

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.greyMedium),
                    foregroundColor: AppTheme.greyMedium,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Purchase credits using the billing service
  /// Credits are added via Stripe webhook (NOT manually here!)
  Future<void> _purchaseCredits(
    BuildContext context,
    WidgetRef ref,
    CreditPackage package,
  ) async {
    final billingService = ref.read(billingServiceProvider);
    final result = await billingService.purchaseCredits(context, package);

    if (!context.mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment Successful! ${result.creditsAdded} credits will be added shortly.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (result.errorMessage != null &&
               result.errorMessage != 'Payment cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Dev mode banner showing current environment
class _DevModeBanner extends StatelessWidget {
  final AppConfig config;

  const _DevModeBanner({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sunsetGold.withOpacity(0.1),
        border: Border.all(color: AppTheme.sunsetGold, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                config.environment.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '${config.environment.displayName} Mode',
                style: const TextStyle(
                  color: AppTheme.sunsetGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Credit System: ${config.enableCreditSystem ? "Enabled" : "Disabled"}\n'
            '• Stripe Payments: ${config.enableStripePayments ? "Enabled" : "Disabled"}',
            style: const TextStyle(
              color: AppTheme.parchment,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dev mode credit controls for testing
class _DevCreditControls extends StatelessWidget {
  final WidgetRef ref;

  const _DevCreditControls({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Developer Controls',
            style: TextStyle(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DevButton(
                label: '+ 50 Credits',
                onTap: () => _addTestCredits(ref, 50),
              ),
              _DevButton(
                label: '+ 150 Credits',
                onTap: () => _addTestCredits(ref, 150),
              ),
              _DevButton(
                label: '+ 500 Credits',
                onTap: () => _addTestCredits(ref, 500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Note: Credit balance is for display only in dev mode',
            style: TextStyle(
              color: AppTheme.greyMedium,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTestCredits(WidgetRef ref, int amount) async {
    final billingService = ref.read(billingServiceProvider);
    await billingService.addCreditsManually(amount, 'Dev Mode Test');
  }
}

class _DevButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DevButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.parchment,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Credit package card widget
class _CreditOptionCard extends StatelessWidget {
  final CreditPackage package;
  final VoidCallback onTap;

  const _CreditOptionCard({
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF383531),
          borderRadius: BorderRadius.circular(16),
          border: package.isPopular
              ? Border.all(color: AppTheme.sunsetGold, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (package.isPopular)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.sunsetGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ),
                Text(
                  '${package.credits} Credits',
                  style: const TextStyle(
                    color: AppTheme.parchment,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${package.label} • ${package.description}',
                  style: const TextStyle(
                    color: AppTheme.stone,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.charcoal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                package.formattedPrice,
                style: const TextStyle(
                  color: AppTheme.parchment,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
