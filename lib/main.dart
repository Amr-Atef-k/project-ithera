import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // To access the device's camera
import 'package:ithera/splashscreen.dart';
import 'SignInScreen.dart';
import 'home.dart';
import 'services/user_prefs.dart'; // Manages user preferences (e.g., remember me, saved credentials)
import 'database_helper.dart'; // Manages local SQLite DB operations

// Global list to store available device cameras
List<CameraDescription> cameras = [];

void main() async {
  // Ensure widgets and plugins are fully initialized before app runs
  WidgetsFlutterBinding.ensureInitialized();
  // Retrieve and store all available cameras on the device
  cameras = await availableCameras();
  // Run the root widget of the app
  runApp(MyApp());
}

// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // Determines which screen to show first based on user preferences
  Future<Widget> _getInitialScreen() async {
    final rememberMe = await UserPrefs.getRememberMe(); // Check if "Remember Me" was selected

    if (rememberMe) {
      final email = await UserPrefs.getEmail(); // Get saved email
      final password = await UserPrefs.getPassword(); // Get saved password

      if (email != null && password != null) {
        final dbHelper = DatabaseHelper(); // DB helper to check credentials
        final user = await dbHelper.getUserByEmailAndPassword(email, password);

        if (user != null) {
          await UserPrefs.saveUserId(user.id!); // Save user ID for later use
          return HomeScreen(); // Login successful, go to home screen
        }
      }
    }

    return SignInScreen(); // Default to sign-in if credentials are missing or invalid
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the "debug" banner
      home: SplashScreenWrapper(
        nextScreenFuture: _getInitialScreen(), // Show splash, then route to appropriate screen
      ),
    );
  }
}

// A stateful widget that wraps the splash screen
class SplashScreenWrapper extends StatefulWidget {
  final Future<Widget> nextScreenFuture; // Future of the next screen to navigate to

  const SplashScreenWrapper({super.key, required this.nextScreenFuture});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen(); // Begin splash logic
  }

  // Waits for 3 seconds, then navigates to the next screen
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Splash screen duration
    final nextScreen = await widget.nextScreenFuture; // Determine next screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => nextScreen), // Replace splash with next screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Display the splash screen UI
  }
}
