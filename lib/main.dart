import 'package:expense_tracker/config/router.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/provider/authentication/auth_provider.dart';
import 'package:expense_tracker/provider/loan/loan_provider.dart';
import 'package:expense_tracker/styles/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoanProviderImpl()),
        ChangeNotifierProvider(create: (_) => AuthenticationProviderImpl()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent, scrolledUnderElevation: 0),
          scaffoldBackgroundColor: whiteColor,
          primaryColor: Colors.greenAccent,
        ),
      ),
    );
  }
}
