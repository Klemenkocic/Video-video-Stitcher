import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/credit_repository.dart';
import '../../../data/services/stripe_service.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final creditsAsync = ref.watch(userCreditsProvider);

    return Scaffold(
      backgroundColor: AppTheme.black, // Monochrome
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  color: AppTheme.surfaceDark, // Monochrome card
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CREDITS',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.greyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    creditsAsync.when(
                      data: (credits) => Text(
                        '$credits',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white)
                      ),
                      error: (_, __) => const Text('Error', style: TextStyle(color: AppTheme.greyMedium)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Top Up Options
              Text(
                'Top Up',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.white,
                    ),
              ),
              const SizedBox(height: 16),
              
              _CreditOptionCard(
                amount: 50,
                price: '€5.00',
                label: 'Starter Pack',
                onTap: () => _purchaseCredits(context, ref, 50),
              ),
              const SizedBox(height: 12),
              _CreditOptionCard(
                amount: 150,
                price: '€12.00',
                label: 'Creator Value',
                isPopular: true,
                onTap: () => _purchaseCredits(context, ref, 150),
              ),
              const SizedBox(height: 12),
              _CreditOptionCard(
                amount: 500,
                price: '€35.00',
                label: 'Pro Studio',
                onTap: () => _purchaseCredits(context, ref, 500),
              ),

              const SizedBox(height: 32),
              
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

  Future<void> _purchaseCredits(BuildContext context, WidgetRef ref, int amount) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true, // Important: use root navigator
        builder: (_) => Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white),
        ),
      );

      final stripeService = ref.read(stripeServiceProvider);
      
      // Map credit amounts to price in cents
      int priceInCents = 1000;
      if (amount == 50) priceInCents = 500;
      if (amount == 150) priceInCents = 1200;
      if (amount == 500) priceInCents = 3500;

      final initialized = await stripeService.initPaymentSheet(priceInCents);

      if (!initialized) {
        throw Exception('Failed to initialize payment');
      }

      // Remove loader using root navigator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Present Payment Sheet
      final success = await stripeService.presentPaymentSheet();
      
      if (success) {
        await ref.read(creditRepositoryProvider).addCredits(amount);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Successful! Credits added.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Payment cancelled')),
          );
        }
      }
    } catch (e) {
      // Safe pop with mounted check and root navigator
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _CreditOptionCard extends StatelessWidget {
  final int amount;
  final String price;
  final String label;
  final bool isPopular;
  final VoidCallback onTap;

  const _CreditOptionCard({
    required this.amount,
    required this.price,
    required this.label,
    required this.onTap,
    this.isPopular = false,
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
          border: isPopular ? Border.all(color: AppTheme.sunsetGold, width: 2) : null,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.sunsetGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.charcoal
                      ),
                    ),
                  ),
                Text(
                  '$amount Credits',
                  style: const TextStyle(
                    color: AppTheme.parchment,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.stone, fontSize: 13),
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
                price,
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
