import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/prefs_keys.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/datasources/auth_local_datasource.dart';
import 'login_page.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    bool completed = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final localDs = AuthLocalDataSourceImpl(prefs);
      completed = await localDs.isOnboardingCompleted();
    } catch (_) {
      completed = false;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            completed ? const LoginPage() : const OnboardingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.appLogo,
              width: 130,
              height: 130,
              errorBuilder: (_, _, _) => const Icon(
                Icons.movie,
                color: AppColors.primary,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}