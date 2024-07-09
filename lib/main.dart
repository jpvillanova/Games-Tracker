import 'package:flutter/material.dart';
import 'welcome.dart';
// import 'login.dart';
import 'register.dart';
import 'dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Games Tracker',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        // '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
