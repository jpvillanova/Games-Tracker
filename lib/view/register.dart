import 'package:flutter/material.dart';
import '../controller/login_controller.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() =>
      RegisterState(); // Updated to use the new public class name
}

class RegisterState extends State<Register> {
  // Renamed to make it public
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _controller = LoginController();

  void _register() async {
    int result = await _controller.registerUser(
      _usernameController.text,
      _passwordController.text,
    );
    if (!mounted) return; // Check if the widget is still mounted
    if (result != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
