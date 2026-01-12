/// Billing and pricing constants - single source of truth
class BillingConstants {
  // ═══════════════════════════════════════
  // CREDIT COSTS
  // ═══════════════════════════════════════

  /// Cost in credits to generate a simple video transition
  static const int videoGenerationCost = 10;

  // ═══════════════════════════════════════
  // CREDIT PACKAGES
  // ═══════════════════════════════════════

  /// Starter pack - good for 5 videos
  static const CreditPackage starterPack = CreditPackage(
    credits: 50,
    priceEuros: 5.00,
    label: 'Starter Pack',
    description: '5 travel videos',
    isPopular: false,
  );

  /// Value pack - most popular, good for 15 videos
  static const CreditPackage valuePack = CreditPackage(
    credits: 150,
    priceEuros: 12.00,
    label: 'Creator Value',
    description: '15 travel videos',
    isPopular: true,
  );

  /// Pro pack - best value, good for 50 videos
  static const CreditPackage proPack = CreditPackage(
    credits: 500,
    priceEuros: 35.00,
    label: 'Pro Studio',
    description: '50 travel videos',
    isPopular: false,
  );

  /// All available credit packages
  static const List<CreditPackage> allPackages = [
    starterPack,
    valuePack,
    proPack,
  ];

  // ═══════════════════════════════════════
  // CONVERSION FORMULAS
  // ═══════════════════════════════════════

  /// Convert euros to cents (for Stripe)
  static int eurosToCents(double euros) => (euros * 100).round();

  /// Convert cents to credits
  /// Formula: 100 cents = 10 credits (10 cents per credit)
  /// This matches the webhook logic in stripe-webhook/index.ts
  static int creditsFromCents(int cents) => cents ~/ 10;

  /// Convert credits to cents (inverse of creditsFromCents)
  static int creditsToCents(int credits) => credits * 10;

  /// Calculate how many videos user can generate with given credits
  static int videosFromCredits(int credits) =>
      credits ~/ videoGenerationCost;

  /// Format price for display
  static String formatPrice(double euros) => '€${euros.toStringAsFixed(2)}';
}

/// Represents a credit package available for purchase
class CreditPackage {
  /// Number of credits in this package
  final int credits;

  /// Price in euros
  final double priceEuros;

  /// Display label for the package
  final String label;

  /// Description text (e.g., "5 travel videos")
  final String description;

  /// Whether this package should be highlighted as most popular
  final bool isPopular;

  const CreditPackage({
    required this.credits,
    required this.priceEuros,
    required this.label,
    required this.description,
    required this.isPopular,
  });

  /// Get price in cents (for Stripe API)
  int get priceInCents => BillingConstants.eurosToCents(priceEuros);

  /// Get formatted price string
  String get formattedPrice => BillingConstants.formatPrice(priceEuros);

  /// Calculate how many videos user can generate with this package
  int get videoCount => BillingConstants.videosFromCredits(credits);

  @override
  String toString() =>
      'CreditPackage($credits credits, $formattedPrice, $label)';
}
