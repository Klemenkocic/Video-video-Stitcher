# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Traverse is a Flutter mobile application that generates AI-powered video transitions between images using the Fal AI service. Users can create video projects by selecting two images and providing a text prompt, which generates a smooth video transition.

## Development Commands

### Setup
```bash
# Get Flutter dependencies
flutter pub get

# Run code generation for Riverpod providers
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development (auto-generates on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running the App

**IMPORTANT:** This app has environment-aware configuration for development and production.

#### Development Mode (Recommended for Testing)
```bash
# Run in development mode - CREDIT CHECKS DISABLED
flutter run --dart-define=ENVIRONMENT=development

# Or shorter:
flutter run --dart-define=ENVIRONMENT=dev
```

In development mode:
- ✅ Credit system is disabled (unlimited video generation)
- ✅ Stripe payments are disabled
- ✅ Dev mode badge shows in UI
- ✅ Uses your Fal API key credits directly
- ✅ Perfect for testing video generation

#### Production Mode (For Production Builds)
```bash
# Run in production mode - FULL CREDIT SYSTEM ENABLED
flutter run --dart-define=ENVIRONMENT=production

# Or shorter:
flutter run --dart-define=ENVIRONMENT=prod
```

In production mode:
- ✅ Full credit system enabled
- ✅ Stripe payment integration active
- ✅ Users must purchase credits to generate videos

#### Other Options
```bash
# Run on specific device
flutter run -d <device-id> --dart-define=ENVIRONMENT=dev

# Default (no environment specified) = development mode
flutter run
```

### Testing & Quality
```bash
# Run tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format lib/ test/
```

### Build

#### Development Builds (Testing)
```bash
# iOS Simulator - Dev Mode
flutter build ios --simulator --debug --dart-define=ENVIRONMENT=development

# Android - Dev Mode
flutter build apk --debug --dart-define=ENVIRONMENT=dev
```

#### Production Builds (Release)
```bash
# iOS - Production
flutter build ios --release --dart-define=ENVIRONMENT=production

# Android - Production
flutter build apk --release --dart-define=ENVIRONMENT=prod
flutter build appbundle --release --dart-define=ENVIRONMENT=prod

# macOS - Production
flutter build macos --release --dart-define=ENVIRONMENT=production
```

**IMPORTANT:** Always use `ENVIRONMENT=production` for App Store / Play Store releases!

## Architecture

### State Management
The app uses **Riverpod** (flutter_riverpod) with code generation for state management:
- Providers are defined using `@riverpod` annotation
- Generated files have `.g.dart` suffix
- Run `build_runner` when adding/modifying providers

### Project Structure
```
lib/
├── core/
│   ├── config/        # ✨ Environment & billing configuration
│   │   ├── environment.dart          # Environment enum (dev/staging/prod)
│   │   ├── app_config.dart          # AppConfig with Riverpod provider
│   │   └── billing_constants.dart   # All billing costs & packages
│   ├── constants/     # App-wide constants (API keys, function names)
│   ├── router/        # go_router configuration with auth guards
│   └── theme/         # AppTheme with custom colors
├── data/
│   ├── models/        # Data models (Project, ProjectNode)
│   ├── repositories/  # Data layer (Auth, Credit, Video repositories)
│   └── services/      # External services
│       ├── billing_service.dart     # ✨ Unified billing service
│       ├── fal_service.dart         # Fal AI video generation
│       ├── stripe_service.dart      # Stripe payment handling
│       ├── media_service.dart       # Image picker & cropper
│       └── download_service.dart    # Video download & sharing
└── presentation/
    ├── providers/     # Riverpod state providers
    ├── screens/       # Full-screen pages
    └── widgets/       # Reusable UI components

supabase/
├── schema.sql         # Database schema
├── migrations/        # Database migrations
└── functions/         # Edge functions (generate-video, payment-sheet, stripe-webhook)
```

### Key Architecture Patterns

**Environment Configuration System:**
The app uses a sophisticated environment configuration system for dev/prod separation:
- `Environment` enum: Defines available environments (development, staging, production)
- `AppConfig`: Configuration class that reads `ENVIRONMENT` dart-define at build time
- `appConfigProvider`: Riverpod provider for accessing config throughout the app
- **Dev Mode**: Credit checks disabled, Stripe disabled, unlimited video generation
- **Production Mode**: Full billing system, Stripe payments, credit enforcement

**Video Generation Flow:**
1. User adds two images and a text prompt via `ProjectProvider`
2. `ProjectProvider.generateVideo()` checks credits via `BillingService`
3. `BillingService.deductCredits()` checks `AppConfig`:
   - **Dev mode**: Always returns true (bypasses credit check)
   - **Prod mode**: Calls `CreditRepository.deductCredits()` and enforces credits
4. If successful, calls `VideoRepository.generateTransition()`
5. `VideoRepository` uses `FalService` to submit job and poll for results
6. `FalService` calls Supabase Edge Function which interfaces with Fal AI API
7. Generated video URL is returned and saved to project state

**Authentication Flow:**
- Managed by `AuthRepository` using Supabase Auth
- `app_router.dart` redirects based on auth state
- Routes: splash → onboarding/auth → dashboard (authenticated)

**Billing System (New Architecture):**
- `BillingService`: Unified facade for all billing operations
- Coordinates between `CreditRepository` and `StripeService`
- Environment-aware: automatically disables in dev mode
- `BillingConstants`: Single source of truth for all costs and packages
- **Credit Packages**: 50 (€5), 150 (€12), 500 (€35)
- **Video Cost**: 10 credits per generation
- **Stripe Webhook**: Handles credit additions (prevents double-credit bug)
- **Important**: Credits are added via webhook only, NOT in UI code

### Backend Integration

**Supabase:**
- Authentication and user management
- PostgreSQL database with RLS (Row Level Security) policies
- Real-time subscriptions for credits
- Edge Functions for serverless API endpoints

**Edge Functions:**
- `generate-video`: Interfaces with Fal AI API for video generation
- `payment-sheet`: Creates Stripe payment intents
- `stripe-webhook`: Handles Stripe webhook events for credit top-ups

**External APIs:**
- Fal AI: Video generation service (accessed via Supabase Edge Function)
- Stripe: Payment processing for credit purchases

## Important Constants

### Billing Constants (`lib/core/config/billing_constants.dart`)
**Single source of truth for all billing values:**
- `videoGenerationCost`: 10 credits per video
- `starterPack`: 50 credits for €5 (5 videos)
- `valuePack`: 150 credits for €12 (15 videos) - MOST POPULAR
- `proPack`: 500 credits for €35 (50 videos)
- Conversion formula: 100 cents = 10 credits (10 cents per credit)

### App Constants (`lib/core/constants/app_constants.dart`)
- Stripe publishable key and merchant ID
- Supabase URL and anon key
- Edge function names: `generate-video`, `payment-sheet`

### Environment Variables (Build-time)
- `ENVIRONMENT`: Set via `--dart-define=ENVIRONMENT=<value>`
- Values: `development`, `staging`, `production`
- Default (if not set): `development`

## Code Generation

This project uses `build_runner` for code generation:
- Riverpod providers: Files with `@riverpod` annotation generate `.g.dart` files
- go_router: Route configuration generates routing code
- Always run `flutter pub run build_runner build --delete-conflicting-outputs` after modifying annotated files

## Common Workflows

### Adding a New Provider
1. Create file with `@riverpod` annotation
2. Add `part 'filename.g.dart';` directive
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. Import and use with `ref.watch(providerName)` or `ref.read(providerName)`

### Adding a New Screen
1. Create screen in `lib/presentation/screens/`
2. Add route in `lib/core/router/app_router.dart`
3. Update navigation in `FloatingNavBar` if it's a main tab

### Modifying Video Generation Logic
- Service layer: `lib/data/services/fal_service.dart`
- Repository layer: `lib/data/repositories/video_repository.dart`
- Provider layer: `lib/presentation/providers/project_provider.dart`
- Backend: `supabase/functions/generate-video/index.ts`

### Working with Billing System
- **UI Layer**: `AccountScreen` displays credits and purchase options
- **Service Layer**: `BillingService` coordinates all billing operations
- **Repository Layer**: `CreditRepository` manages database interactions
- **Config Layer**: `AppConfig` controls whether billing is enabled
- **Constants**: `BillingConstants` defines all costs and packages
- **Stripe Flow**: UI → BillingService → StripeService → Webhook → Credits added

### Testing Video Generation (Development Mode)
1. Run app with `--dart-define=ENVIRONMENT=development`
2. Login/signup to create account
3. Navigate to Dashboard
4. Look for 🔧 DEVELOPMENT badge (confirms dev mode)
5. Add two images and text prompt
6. Tap "Generate Video"
7. **Credit check is bypassed automatically** ✅
8. Video generation proceeds using your Fal API key
9. Wait for video to complete (polling status)

## Database Schema

Key tables:
- `profiles`: User data, credits, Stripe customer ID
- `projects`: User video projects with nodes (JSONB), status, and output URLs
- `credit_transactions`: Audit log of all credit changes

RPC Functions:
- `deduct_credits(amount, description)`: Returns boolean, only deducts if sufficient
- `top_up_credits(amount, description)`: Adds credits and logs transaction

## Environment Configuration Deep Dive

### How It Works
The app uses Dart's `--dart-define` feature to set environment variables at compile time:
```dart
const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
```

This value is read by `Environment.current` and used to create the appropriate `AppConfig`.

### Environment Comparison

| Feature | Development | Production |
|---------|-------------|------------|
| Credit System | ❌ Disabled | ✅ Enabled |
| Credit Checks | Always pass | Enforced |
| Stripe Payments | ❌ Disabled | ✅ Enabled |
| Dev UI Badge | ✅ Visible | ❌ Hidden |
| Video Generation | Unlimited | Costs 10 credits |
| Fal API Usage | Direct (your key) | Via credits |
| Debug Logging | Verbose | Errors only |

### Visual Indicators

**Development Mode UI:**
- 🔧 DEVELOPMENT badge in top-right of Dashboard
- Dev Mode banner on Account screen
- "UNLIMITED" badge on credit display
- ∞ symbol instead of credit count
- Developer controls (manual credit buttons)

**Production Mode UI:**
- No dev badges or banners
- Normal credit count display
- Stripe payment options visible
- "Top Up" section with packages

### When to Use Each Environment

**Use Development Mode When:**
- Testing video generation locally
- Developing new features
- QA testing without credit restrictions
- Debugging video generation issues
- Running in Xcode simulator

**Use Production Mode When:**
- Building for App Store / Play Store
- Testing the complete purchase flow
- Verifying Stripe integration
- Final QA before release
- Beta testing with real payments

### VS Code Launch Configuration

Add to `.vscode/launch.json`:
```json
{
  "configurations": [
    {
      "name": "Dev Mode",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENVIRONMENT=development"]
    },
    {
      "name": "Production Mode",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENVIRONMENT=production"]
    }
  ]
}
```

## Known Implementation Details

- Project nodes are stored as JSONB in database but managed as Dart models in app
- Images should be uploaded to storage and passed as URLs (not local file paths) for video generation
- Video generation uses polling mechanism with 60 attempts at 2-second intervals (max 2 minutes)
- Auth state changes trigger router redirects automatically via Riverpod watch
- The app uses a custom floating navigation bar instead of standard bottom nav
- **Credit addition happens ONLY via Stripe webhook** (not in UI) to prevent double-crediting
- Dev mode is detected via `kDebugMode && !config.isProduction` for safety
