import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ithera/profile.dart';
import 'articles.dart';
import 'beforetest.dart';
import 'chatbot.dart';
import 'services/user_prefs.dart';
import 'SignInScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';
import 'class/users.dart';
import 'breathingtest.dart';
import 'soothing_sounds.dart';
import 'videos.dart'; // Import the new VideosScreen

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
          future: UserPrefs.getUserId(),
          builder: (context, userIdSnapshot) {
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
            if (userIdSnapshot.hasError || userIdSnapshot.data == null) {
              return Text(
                'Welcome',
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            final userId = userIdSnapshot.data!;
            return FutureBuilder<User?>(
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
                if (userSnapshot.hasError || userSnapshot.data == null) {
                  return Text(
                    'Welcome',
                    style: GoogleFonts.lora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
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
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color(0xFF333333),
            height: 2.0,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFA3C6C4),
              ),
              child: Center(
                child: Text(
                  "Menu",
                  style: GoogleFonts.lora(
                    color: const Color(0xFF333333),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticlesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Color(0xFF333333)),
              title: Text(
                "Online Videos",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideosScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.air, color: Color(0xFF333333)),
              title: Text(
                "Breathing Exercise",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BreathingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Color(0xFF333333)),
              title: Text(
                "Soothing Sounds",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SoothingSoundsScreen()),
                );
              },
            ),
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
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF333333)),
              title: Text(
                "Log out",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: const Color(0xFFF9E8E8).withOpacity(0.8),
          child: Stack(
            children: [
              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 150, // Increased from 100 to 150
                          width: 150, // Increased from 100 to 150
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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