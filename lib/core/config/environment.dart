/// Application environment configuration
enum Environment {
  /// Development environment - for local testing
  /// - Credit checks disabled
  /// - Uses Fal API key credits directly
  /// - Debug logging enabled
  development,

  /// Staging environment - for pre-production testing
  /// - All features enabled
  /// - Uses test Stripe keys
  staging,

  /// Production environment - for live app
  /// - Full credit system enabled
  /// - Live Stripe integration
  /// - Production API endpoints
  production;

  /// Get current environment from dart-define or default to development
  static Environment get current {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }

  /// Check if running in development mode
  bool get isDevelopment => this == Environment.development;

  /// Check if running in production mode
  bool get isProduction => this == Environment.production;

  /// Check if running in staging mode
  bool get isStaging => this == Environment.staging;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Get emoji indicator for UI
  String get emoji {
    switch (this) {
      case Environment.development:
        return '🔧';
      case Environment.staging:
        return '⚙️';
      case Environment.production:
        return '🚀';
    }
  }
}
