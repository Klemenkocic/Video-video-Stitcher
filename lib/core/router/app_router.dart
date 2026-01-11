import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/videos/videos_screen.dart';
import '../../presentation/screens/account/account_screen.dart';
import '../../presentation/widgets/navigation/floating_nav_bar.dart';
import '../../data/repositories/auth_repository.dart';

part 'app_router.g.dart';

// Shell Scaffold for persistent NavBar
class MainShellScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainShellScaffold({super.key, required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          FloatingNavBar(currentIndex: currentIndex),
        ],
      ),
    );
  }
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      // -- Non-Shell Routes (full screen)
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) {
          return authState.when(
            data: (user) {
              if (user != null) return '/dashboard';
              return '/onboarding';
            },
            loading: () => null, 
            error: (_, __) => '/auth',
          );
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // -- Shell Routes (with persistent NavBar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScaffold(
            currentIndex: navigationShell.currentIndex,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/videos',
                builder: (context, state) => const VideosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation == '/auth';
      final isSplashRoute = state.matchedLocation == '/';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      
      if (isOnboardingRoute) return null;

      if (!isLoggedIn && !isAuthRoute && !isSplashRoute && !isOnboardingRoute) {
           return '/auth';
      }

      if (isLoggedIn && (isAuthRoute || isOnboardingRoute)) {
          return '/dashboard';
      }

      return null;
    },
  );
}
