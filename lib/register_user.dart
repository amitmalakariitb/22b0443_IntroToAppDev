import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // If registration is successful, you can navigate to the login page or any other page.
      // For now, let's print the newly registered user's email.
      print("Registered user: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      print(
          "Registration failed:Error Code: ${e.code}, Error Message: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), // Set the minimum size of the button
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Set the padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Set the border radius
                ),
                 ),
              child: Text("Register"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), // Set the minimum size of the button
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Set the padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Set the border radius
                ),
                ),
              child: Text(" Login "),
            ),
          ],
        ),
      ),
    );
  }
}
