import 'dart:async';
import 'package:aptech_e_project_flutter/Auth/welcomePage.dart';
import 'package:aptech_e_project_flutter/HomePageindex.dart';
import 'package:flutter/material.dart';
import 'package:aptech_e_project_flutter/Auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer(const Duration(seconds: 3), () {
      // Navigate to LoginScreen after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,  // Background color for splash screen
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Image.asset(
              'assets/images/splash_image01.png',  // Update with your image path
              width: 250,  // Set width as needed
              height: 250, // Set height as needed
            ),
              // SizedBox(height: 10),
              Text(
                'Welcome to Book Store',
                style: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
