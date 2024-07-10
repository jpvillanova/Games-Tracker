import 'package:flutter/material.dart';
import 'view/home.dart';
import 'view/login.dart';
import 'view/register.dart';
import 'view/welcome.dart';

final routes = {
  '/': (context) => const Welcome(),
  '/login': (context) => const Login(),
  '/register': (context) => const Register(),
  '/home': (context) => const Home(),
};

void main() {
  runApp(MaterialApp(
      title: "Games Tracker App",
      debugShowCheckedModeBanner: false,
      routes: routes));
}
