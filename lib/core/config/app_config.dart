import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'environment.dart';

part 'app_config.g.dart';

/// Application configuration based on environment
class AppConfig {
  final Environment environment;
  final bool enableCreditSystem;
  final bool enableStripePayments;
  final bool showDebugInfo;
  final String apiLogLevel;

  const AppConfig({
    required this.environment,
    required this.enableCreditSystem,
    required this.enableStripePayments,
    required this.showDebugInfo,
    required this.apiLogLevel,
  });

  /// Create development configuration
  factory AppConfig.development() {
    return const AppConfig(
      environment: Environment.development,
      enableCreditSystem: false, // Disable credit checks for testing
      enableStripePayments: false, // No payments in dev
      showDebugInfo: true, // Show debug UI elements
      apiLogLevel: 'debug',
    );
  }

  /// Create staging configuration
  factory AppConfig.staging() {
    return const AppConfig(
      environment: Environment.staging,
      enableCreditSystem: true, // Enable credits for testing flow
      enableStripePayments: true, // Use test Stripe keys
      showDebugInfo: true, // Show debug info
      apiLogLevel: 'info',
    );
  }

  /// Create production configuration
  factory AppConfig.production() {
    return const AppConfig(
      environment: Environment.production,
      enableCreditSystem: true, // Full credit system
      enableStripePayments: true, // Live payments
      showDebugInfo: false, // No debug info in production
      apiLogLevel: 'error',
    );
  }

  /// Create config from current environment
  factory AppConfig.fromEnvironment() {
    final env = Environment.current;

    switch (env) {
      case Environment.development:
        return AppConfig.development();
      case Environment.staging:
        return AppConfig.staging();
      case Environment.production:
        return AppConfig.production();
    }
  }

  /// Check if in development mode
  bool get isDevelopment => environment.isDevelopment;

  /// Check if in production mode
  bool get isProduction => environment.isProduction;

  /// Log configuration info (useful for debugging)
  void logConfig() {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('${environment.emoji} App Configuration ${environment.emoji}');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Environment: ${environment.displayName}');
    debugPrint('Credit System: ${enableCreditSystem ? "ENABLED" : "DISABLED"}');
    debugPrint('Stripe Payments: ${enableStripePayments ? "ENABLED" : "DISABLED"}');
    debugPrint('Debug Info: ${showDebugInfo ? "VISIBLE" : "HIDDEN"}');
    debugPrint('Log Level: $apiLogLevel');
    debugPrint('═══════════════════════════════════════');
    debugPrint('');
  }
}

/// Provider for application configuration
/// This is a singleton that provides the config based on build-time environment
@Riverpod(keepAlive: true)
AppConfig appConfig(AppConfigRef ref) {
  final config = AppConfig.fromEnvironment();

  // Log config on first access (only in debug builds)
  if (kDebugMode) {
    config.logConfig();
  }

  return config;
}
