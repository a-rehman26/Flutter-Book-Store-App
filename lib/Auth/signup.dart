import 'package:aptech_e_project_flutter/Auth/login.dart';
import 'package:aptech_e_project_flutter/HomePageindex.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aptech_e_project_flutter/Auth/Widget/bezierContainer.dart';
import 'package:uuid/uuid.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_left, color: Colors.black),
          const Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
        ],
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            fillColor: const Color(0xfff3f3f4),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: _registerUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xfff7892b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      child: const Text('Register Now', style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Already have an account?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(width: 10),
          Text('Login', style: TextStyle(color: Color(0xfff79c4f), fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Book',
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xffe46b10)),
        children: [
          TextSpan(text: 'Stor', style: const TextStyle(color: Colors.black, fontSize: 30)),
          TextSpan(text: 'e', style: const TextStyle(color: Color(0xffe46b10), fontSize: 30)),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: [
        _entryField("Username", _usernameController),
        _entryField("Age", _ageController),
        _entryField("Email", _emailController),
        _entryField("Password", _passwordController, isPassword: true),
      ],
    );
  }

  void _registerUser() async {
    try {
      // Register the user with Firebase Authentication (email and password)
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Prepare user data to store in Firestore
        Map<String, dynamic> userData = {
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "age": _ageController.text.trim(),
          "password": _passwordController.text.trim(),
          "userRole": "user",  // Default role
        };

        // Store user data in Firestore using the Firebase Authentication UID as Document ID
        try {
          await FirebaseFirestore.instance
              .collection('users')  // Firestore collection name
              .doc(userCredential.user!.uid)  // Use the Firebase Auth UID as Document ID
              .set(userData);  // Set the user data

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration successful")));

          // Navigate to HomeScreen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your HomeScreen widget
          );
        } catch (e) {
          print("Error saving user data to Firestore: $e");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save user data")));
        }
      } else {
        print('Error: No user ID available.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register user")));
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      print("Error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: [
            Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * .2),
                    _title(),
                    const SizedBox(height: 50),
                    _emailPasswordWidget(),
                    const SizedBox(height: 20),
                    _submitButton(),
                    SizedBox(height: height * .14),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
