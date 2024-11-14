import 'package:expense_tracker/config/constants.dart';
import 'package:expense_tracker/styles/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.monetization_on_outlined,
              size: 120,
              color: Color(0xFF0FA47F), // Add color here
            ),
            Text(
              appName,
              style: AppTheme.headerStyle(),
            ),
            Text(
              'Smarter way to manage your loans',
              style: AppTheme.titleStyle(),
            )
          ],
        ),
      ),
    );
  }

  void _navigate() {
    Future.delayed(const Duration(seconds: 3), () {
      if (FirebaseAuth.instance.currentUser != null) {
        context.go('/loan_dashboard');
      } else {
        context.go('/register_screen');
      }
    });
  }
}
