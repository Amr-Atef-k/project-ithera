import 'package:flutter/material.dart';
import 'dart:async';
import 'SignInScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading or initialization tasks here
    Timer(Duration(seconds: 4), () { // Duration for splash screen visibility
      // Handle If the user logged in before( --> Home screen) or first time( --> SignIn Screen)
      Navigator.pushReplacement( // Navigate to the main screen after splash
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()), // Replace MainScreen with your actual main screen widget
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F0F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Circular image container with pink outline
            Container(
              width: 100, // Adjust size as needed
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFA3C6C4), // Match pink color
                  width: 2, // Adjust border width as needed
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/avatar.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20), // Spacing between elements
            Text(
              'Welcome to IThera',
              style: TextStyle(
                fontSize: 24, // Adjust font size as needed
                color: Colors.black, // Match text color
                fontWeight: FontWeight.w500, // Adjust font weight as needed
              ),
            ),
            SizedBox(height: 20), // Spacing between elements
            // Loading bar (using LinearProgressIndicator for a simple bar)
            SizedBox(
              width: 200, // Adjust width as needed
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA3C6C4)), // Match pink color
                backgroundColor: Colors.grey[200], // Adjust background color as needed
              ),
            ),
            SizedBox(height: 10), // Spacing between elements
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16, // Adjust font size as needed
                color: Colors.grey[600], // Match text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}