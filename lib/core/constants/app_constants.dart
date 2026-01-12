class AppConstants {
  // App Config
  static const String appName = 'Traverse';
  
  // Backend Functions
  static const String functionGenerateVideo = 'generate-video';
  static const String functionPaymentSheet = 'payment-sheet';

  // Stripe Config
  static const String stripePublishableKey = 'pk_test_51RcrjCQK1t3Rxn8QL0pBrq49kcP2WMXBaHGlDZeCmlMuMsgEVIFfbYQUzdfmDnv1tkU5ce02iqYvCd0Jr8TLmXuz00HYTA4X0H';
  static const String stripeMerchantId = 'merchant.com.traverse';

  // Supabase Config
  // URL inferred from your key's project ref: rkrtlenampqbnejxwmmk
  static const String supabaseUrl = 'https://rkrtlenampqbnejxwmmk.supabase.co'; 
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJrcnRsZW5hbXBxYm5lanh3bW1rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwOTc0NDUsImV4cCI6MjA4MzY3MzQ0NX0.FLQhsyczPYpkW1XWRWwC1IDx9qbRmHeRSZeC-zE4k5E';

  // Credit Costs
  static const int simpleVideoCost = 10;
}
