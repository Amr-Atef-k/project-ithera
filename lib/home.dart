import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ithera/profile.dart';
import 'articles.dart';
import 'beforetest.dart';
import 'chatbot.dart';
import 'services/user_prefs.dart';
import 'SignInScreen.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the URL package for external links
import 'database_helper.dart'; // Import DatabaseHelper to fetch user data
import 'class/users.dart'; // Import User class for type definition
import 'breathingtest.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Static method to launch URLs with error handling
  static Future<void> launchURL(BuildContext context, Uri uri) async {
    try {
      debugPrint('Attempting to launch URL: $uri');
      if (await canLaunchUrl(uri)) {
        debugPrint('canLaunchUrl returned true for: $uri');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('Successfully launched: $uri');
      } else {
        debugPrint('canLaunchUrl returned false for: $uri');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              uri.scheme == 'mailto'
                  ? 'Could not open email app. Please ensure Gmail or another email app is set as default.'
                  : 'Could not open URL',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uri.scheme == 'mailto'
                ? 'Could not open email app. Please ensure Gmail or another email app is set as default.'
                : 'Could not open URL',
          ),
        ),
      );
    }
  }

  // Home Screen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: FutureBuilder<int?>(
          // Fetch the user ID from UserPrefs
          future: UserPrefs.getUserId(),
          builder: (context, userIdSnapshot) {
            // Check if the data is still loading
            if (userIdSnapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              );
            }
            // Check for errors or null data
            if (userIdSnapshot.hasError || userIdSnapshot.data == null) {
              return Text(
                'Welcome',
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            // Get the user ID
            final userId = userIdSnapshot.data!;
            return FutureBuilder<User?>(
              // Fetch user data from the database
              future: DatabaseHelper().getUserById(userId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  );
                }
                // Check for errors or null user data
                if (userSnapshot.hasError || userSnapshot.data == null) {
                  return Text(
                    'Welcome',
                    style: GoogleFonts.lora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                // Get the user object and displays first name
                final user = userSnapshot.data!;
                return Text(
                  'Welcome ${user.firstName}',
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            );
          },
        ),

        // The Drawer Widget
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        // The profile Widget
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],

        // Add a divider below the app bar
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color(0xFF333333),
            height: 2.0,
          ),
        ),
      ),

      // Define the drawer menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFA3C6C4),
              ),
              child: Text(
                "Menu",
                style: GoogleFonts.lora(
                  color: const Color(0xFF333333),
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article_sharp, color: Color(0xFF333333)),
              title: Text(
                "Online Articles",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
              // Navigates to Articles and FAQs Screen
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticlesScreen()),
                );
              },
            ),

            // Breathing Test menu item
            ListTile(
              leading: const Icon(Icons.air, color: Color(0xFF333333)),
              title: Text(
                "Breathing Test",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
              // Navigates to BreathingScreen
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BreathingScreen()),
                );
              },
            ),

            // Locate a near therapist
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF333333)),
              title: Text(
                "Locate a near therapist",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                HomeScreen.launchURL(context, Uri.parse('https://www.google.com/maps/search/?api=1&query=therapist'));
              },
            ),

            // Navigates to sign in Screen
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF333333)),
              title: Text(
                "Log out",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
              // clears user data and navigates to sign in screen
              onTap: () async {
                await UserPrefs.clearUserId();
                await UserPrefs.clearRememberMe();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // The Body UI
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            // The background image
            image: AssetImage('assets/image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Overlay with a semi-transparent color
          color: const Color(0xFFF9E8E8).withOpacity(0.8),
          child: Stack(
            children: [
              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      // Centers the logo
                      child: ClipOval(
                        child: Image.asset(
                          'assets/avatar.png',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Empty Space
                    const SizedBox(height: 30),
                    // "App info" container
                    Container(
                      width: 250,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA3C6C4), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          "info about the application",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // "Take the test" button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3C6C4),
                        foregroundColor: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BeforeTest()),
                        );
                      },
                      child: Text(
                        "TAKE THE TEST",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // "Chatbot" button position
              Positioned(
                right: 20,
                bottom: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Chat with Thera",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      backgroundColor: const Color(0xFFA3C6C4),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Chatbot()),
                        );
                      },
                      child: const Icon(Icons.chat, color: Color(0xFF333333)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}