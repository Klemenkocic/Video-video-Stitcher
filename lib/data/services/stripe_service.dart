import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

part 'stripe_service.g.dart';

class StripeService {
  StripeService() {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.com.traverse';
    Stripe.instance.applySettings();
  }

  // Fetch keys from backend and initialize sheet
  Future<bool> initPaymentSheet(int amountInCents) async {
    try {
      // 1. Call Edge Function to get secrets
      final response = await Supabase.instance.client.functions.invoke(
        'payment-sheet',
        body: {'amount': amountInCents, 'currency': 'eur'},
      );
      
      final data = response.data;
      
      if (data == null || data['error'] != null) {
        throw Exception(data?['error'] ?? 'Failed to fetch payment params');
      }

      // 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Traverse',
          paymentIntentClientSecret: data['paymentIntent'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['customer'],
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppTheme.terracotta,
              background: AppTheme.charcoal,
              componentBackground: Color(0xFF383531),
              componentText: Colors.white,
              primaryText: Colors.white,
              secondaryText: AppTheme.stone,
              placeholderText: AppTheme.stone,
              icon: AppTheme.terracotta,
              error: Colors.redAccent,
            ),
          ),
        ),
      );
      return true;
    } catch (e) {
      print('Stripe Init Error: $e');
      return false;
    }
  }

  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      print('Payment Cancelled/Failed: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      print('Payment Error: $e');
      return false;
    }
  }


}

@riverpod
StripeService stripeService(StripeServiceRef ref) {
  return StripeService();
}
