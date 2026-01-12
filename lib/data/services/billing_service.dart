import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/app_config.dart';
import '../../core/config/billing_constants.dart';
import '../repositories/credit_repository.dart';
import 'stripe_service.dart';

part 'billing_service.g.dart';

/// Result of a purchase attempt
class PurchaseResult {
  final bool success;
  final String? errorMessage;
  final int? creditsAdded;

  const PurchaseResult.success(this.creditsAdded)
      : success = true,
        errorMessage = null;

  const PurchaseResult.cancelled()
      : success = false,
        errorMessage = 'Payment cancelled',
        creditsAdded = null;

  const PurchaseResult.error(this.errorMessage)
      : success = false,
        creditsAdded = null;
}

/// Unified billing service that coordinates credit management and payments
/// This service acts as a facade for all billing-related operations
class BillingService {
  final AppConfig _config;
  final CreditRepository _creditRepo;
  final StripeService? _stripeService;

  BillingService({
    required AppConfig config,
    required CreditRepository creditRepo,
    StripeService? stripeService,
  })  : _config = config,
        _creditRepo = creditRepo,
        _stripeService = stripeService;

  // ═══════════════════════════════════════
  // CREDIT OPERATIONS
  // ═══════════════════════════════════════

  /// Watch user's credit balance in real-time
  Stream<int> watchCredits() => _creditRepo.watchCredits();

  /// Attempt to deduct credits for an operation
  /// Returns true if successful, false if insufficient credits
  ///
  /// In development mode, this always returns true (credit checks disabled)
  Future<bool> deductCredits(int amount, String description) async {
    // Development mode: bypass credit check
    if (!_config.enableCreditSystem) {
      developer.log(
        '[DEV MODE] Credit check bypassed - $description',
        name: 'BillingService',
      );
      return true;
    }

    // Production mode: check and deduct credits
    try {
      final success = await _creditRepo.deductCredits(amount, description);

      if (success) {
        developer.log(
          'Credits deducted: $amount for $description',
          name: 'BillingService',
        );
      } else {
        developer.log(
          'Insufficient credits: needed $amount for $description',
          name: 'BillingService',
        );
      }

      return success;
    } catch (e) {
      developer.log(
        'Credit deduction failed: $e',
        error: e,
        name: 'BillingService',
      );
      return false;
    }
  }

  /// Manually add credits (for testing/admin purposes only)
  /// Should not be called in production builds
  Future<void> addCreditsManually(int amount, String description) async {
    if (_config.isProduction) {
      developer.log(
        'WARNING: Attempted manual credit addition in production!',
        name: 'BillingService',
      );
      return;
    }

    await _creditRepo.addCredits(amount);
    developer.log(
      'Manual credits added: $amount - $description',
      name: 'BillingService',
    );
  }

  // ═══════════════════════════════════════
  // PAYMENT OPERATIONS
  // ═══════════════════════════════════════

  /// Purchase credits using Stripe
  ///
  /// This handles the entire payment flow:
  /// 1. Initializes Stripe payment sheet
  /// 2. Presents payment UI to user
  /// 3. Returns result (success/cancelled/error)
  ///
  /// NOTE: Credits are added via webhook, not here!
  /// This prevents double-crediting bugs
  Future<PurchaseResult> purchaseCredits(
    BuildContext context,
    CreditPackage package,
  ) async {
    // Check if payments are enabled
    if (!_config.enableStripePayments) {
      developer.log(
        '[DEV MODE] Stripe payments disabled',
        name: 'BillingService',
      );
      return const PurchaseResult.error(
        'Payments are disabled in this environment',
      );
    }

    if (_stripeService == null) {
      return const PurchaseResult.error('Payment service not initialized');
    }

    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (_) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      // Initialize payment sheet with Stripe
      developer.log(
        'Initializing payment for ${package.credits} credits (${package.formattedPrice})',
        name: 'BillingService',
      );

      final initialized = await _stripeService!.initPaymentSheet(
        package.priceInCents,
      );

      // Remove loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!initialized) {
        return const PurchaseResult.error('Failed to initialize payment');
      }

      // Present payment sheet to user
      final paymentSuccess = await _stripeService!.presentPaymentSheet();

      if (paymentSuccess) {
        developer.log(
          'Payment successful - credits will be added via webhook',
          name: 'BillingService',
        );
        return PurchaseResult.success(package.credits);
      } else {
        developer.log('Payment cancelled by user', name: 'BillingService');
        return const PurchaseResult.cancelled();
      }
    } catch (e, stack) {
      developer.log(
        'Purchase failed',
        error: e,
        stackTrace: stack,
        name: 'BillingService',
      );

      // Safe cleanup
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }

      return PurchaseResult.error(e.toString());
    }
  }

  // ═══════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════

  /// Get all available credit packages
  List<CreditPackage> getAvailablePackages() => BillingConstants.allPackages;

  /// Calculate video generation cost
  int getVideoGenerationCost() => BillingConstants.videoGenerationCost;

  /// Check if user has enough credits for an operation
  Future<bool> hasEnoughCredits(int required) async {
    if (!_config.enableCreditSystem) return true;

    // Get current credits from stream
    final currentCredits = await watchCredits().first;
    return currentCredits >= required;
  }
}

/// Provider for billing service
@riverpod
BillingService billingService(BillingServiceRef ref) {
  final config = ref.watch(appConfigProvider);
  final creditRepo = ref.watch(creditRepositoryProvider);

  // Only initialize Stripe if payments are enabled
  final stripeService = config.enableStripePayments
      ? ref.watch(stripeServiceProvider)
      : null;

  return BillingService(
    config: config,
    creditRepo: creditRepo,
    stripeService: stripeService,
  );
}
