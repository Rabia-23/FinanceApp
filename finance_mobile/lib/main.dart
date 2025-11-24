import 'package:flutter/material.dart';
import 'widgets/main_layout.dart';
import 'pages/registration.dart';
import 'pages/home.dart';
import 'pages/subscription.dart';
import 'pages/currency.dart';
import 'pages/transactions.dart';
import 'pages/goals.dart';

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        // MainLayout ile sarmala
        '/home': (context) => const MainLayout(
              currentRoute: '/home',
              child: HomePage(),
            ),
        '/subscriptions': (context) => const MainLayout(
              currentRoute: '/subscriptions',
              child: SubscriptionPage(),
            ),
        '/currency': (context) => const MainLayout(
              currentRoute: '/currency',
              child: CurrencyPage(),
            ),
        '/transactions': (context) => const MainLayout(
              currentRoute: '/transactions',
              child: TransactionsPage(),
            ),
        '/goals': (context) => const MainLayout(
              currentRoute: '/goals',
              child: GoalsPage(),
            ),
      },
    );
  }
}