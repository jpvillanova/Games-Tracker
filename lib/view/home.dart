import 'package:flutter/material.dart';
import '../helper/auth.dart';
import '../model/user.dart'; // Import the User class

class Home extends StatefulWidget {
  final User? user; // Make user nullable
  const Home({this.user, super.key}); // Remove required keyword

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.user != null ? "Welcome, ${widget.user!.name}" : "Welcome"),
        actions: <Widget>[
          IconButton(
            onPressed: () => Auth.signOut().then((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            }),
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: const Center(
        child: Text("Home Page"),
      ),
    );
  }
}
