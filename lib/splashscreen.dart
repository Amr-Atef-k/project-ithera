// Importing the Flutter material design library for UI components
import 'package:flutter/material.dart';
// Importing the dart:async library for Timer functionality
import 'dart:async';
// Importing the SignInScreen widget for navigation
import 'SignInScreen.dart';

// Defining the SplashScreen widget as a StatefulWidget
class SplashScreen extends StatefulWidget {
  // Overriding the createState method to return the state for this widget
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// Defining the state class for SplashScreen
class _SplashScreenState extends State<SplashScreen> {
  // Overriding the initState method to perform initialization tasks
  @override
  void initState() {
    // Calling the parent class's initState method
    super.initState();
    // Creating a timer to delay navigation for 4 seconds
    Timer(Duration(seconds: 4), () {
      // Navigating to SignInScreen after the splash screen duration
      Navigator.pushReplacement(
        // Using the current context for navigation
        context,
        // Creating a MaterialPageRoute to transition to SignInScreen
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    });
  }

  // Overriding the build method to define the UI of the splash screen
  @override
  Widget build(BuildContext context) {
    // Returning a Scaffold widget as the main structure of the screen
    return Scaffold(
      // Setting the background color of the screen
      backgroundColor: Color(0xFFF6F0F4),
      // Defining the body of the scaffold
      body: Center(
        // Centering the content vertically and horizontally
        child: Column(
          // Aligning children in the center of the column
          mainAxisAlignment: MainAxisAlignment.center,
          // Defining the children widgets of the column
          children: <Widget>[
            // Container for the circular logo image
            Container(
              // Setting the width of the container
              width: 100,
              // Setting the height of the container
              height: 100,
              // Clipping the image to a circular shape
              child: ClipOval(
                // Displaying the logo image from assets
                child: Image.asset(
                  // Path to the logo image
                  'assets/logo.png',
                  // Setting the height of the image
                  height: 100,
                  // Setting the width of the image
                  width: 100,
                  // Ensuring the image fits within the bounds
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Adding vertical spacing between elements
            SizedBox(height: 20),
            // Displaying the welcome text
            Text(
              // Text content
              'Welcome to iThera',
              // Styling the text
              style: TextStyle(
                // Setting the font size
                fontSize: 24,
                // Setting the text color
                color: Colors.black,
                // Setting the font weight
                fontWeight: FontWeight.w500,
              ),
            ),
            // Adding vertical spacing between elements
            SizedBox(height: 20),
            // Container for the loading bar
            SizedBox(
              // Setting the width of the loading bar
              width: 200,
              // Displaying a linear progress indicator
              child: LinearProgressIndicator(
                // Setting the color of the progress bar
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA3C6C4)),
                // Setting the background color of the progress bar
                backgroundColor: Colors.grey[200],
              ),
            ),
            // Adding vertical spacing between elements
            SizedBox(height: 10),
            // Displaying the loading text
            Text(
              // Text content
              'Loading...',
              // Styling the text
              style: TextStyle(
                // Setting the font size
                fontSize: 16,
                // Setting the text color
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}