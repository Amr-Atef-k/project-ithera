import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ithera/splashscreen.dart';
import 'SignInScreen.dart';
import 'home.dart';
import 'services/user_prefs.dart';
import 'database_helper.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final rememberMe = await UserPrefs.getRememberMe();
    if (rememberMe) {
      final email = await UserPrefs.getEmail();
      final password = await UserPrefs.getPassword();
      if (email != null && password != null) {
        final dbHelper = DatabaseHelper();
        final user = await dbHelper.getUserByEmailAndPassword(email, password);
        if (user != null) {
          await UserPrefs.saveUserId(user.id!);
          return HomeScreen();
        }
      }
    }
    return SignInScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenWrapper(
        nextScreenFuture: _getInitialScreen(),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  final Future<Widget> nextScreenFuture;

  const SplashScreenWrapper({super.key, required this.nextScreenFuture});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));
    final nextScreen = await widget.nextScreenFuture;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}