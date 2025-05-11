// Import necessary Flutter and external packages
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignUpScreen.dart';
import 'database_helper.dart';
import 'services/user_prefs.dart';
import 'home.dart';

// StatefulWidget for the Sign In screen
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers to handle input for email and password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables for 'Remember Me' checkbox and password visibility
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // Key used to validate the form
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load saved email/password if 'Remember Me' was previously enabled
    _loadSavedCredentials();
  }

  // Load credentials if 'Remember Me' is true
  Future<void> _loadSavedCredentials() async {
    final rememberMe = await UserPrefs.getRememberMe();
    if (rememberMe) {
      final email = await UserPrefs.getEmail();
      final password = await UserPrefs.getPassword();
      if (email != null && password != null) {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    }
  }

  // Sign in logic
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      // If user is found, navigate to HomeScreen and optionally save credentials
      if (user != null) {
        await UserPrefs.saveUserId(user.id!);
        await UserPrefs.saveRememberMe(
          rememberMe: _rememberMe,
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
      } else {
        // If user not found, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  // Clean up controllers when widget is disposed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind app bar
      extendBody: true, // Extend body into system UI areas
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard shows
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'Sign In',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: MediaQuery.of(context).padding.top + 20.0, // Avoid status bar
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0, // Avoid keyboard
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40), // Pushes content downward
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png', // User avatar image
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.lora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email Input Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.roboto(
                        color: const Color(0xFF333333),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.roboto(
                        color: const Color(0xFF333333),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      // Toggle show/hide password
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF333333),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Remember Me Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFFA3C6C4),
                      ),
                      Text(
                        'Remember Me',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Sign In Button
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Navigate to Sign Up screen
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Don’t have an account? Sign Up',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}