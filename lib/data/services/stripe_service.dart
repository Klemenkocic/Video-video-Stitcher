import 'dart:developer' as developer;
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
        AppConstants.functionPaymentSheet,
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
      developer.log('Stripe Init Error', error: e, name: 'StripeService');
      return false;
    }
  }

  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      developer.log('Payment Cancelled/Failed', error: e.error.localizedMessage, name: 'StripeService');
      return false;
    } catch (e) {
      developer.log('Payment Error', error: e, name: 'StripeService');
      return false;
    }
  }
}

@riverpod
StripeService stripeService(StripeServiceRef ref) {
  return StripeService();
}
