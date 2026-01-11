import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

class TraverseApp extends ConsumerWidget {
  const TraverseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme, // Using dark theme as default per requirements
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
