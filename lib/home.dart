import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ithera/profile.dart';
import 'beforetest.dart';
import 'chatbot.dart';
import 'services/user_prefs.dart';
import 'SignInScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart'; // Import DatabaseHelper to fetch user data
import 'class/users.dart'; // Import User class for type definition

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                "Articles and FAQs",
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
            image: AssetImage('assets/image.jpg'),
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
                          'assets/avatar.png',
                          height: 100,
                          width: 100,
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

class ArticlesScreen extends StatelessWidget {
  ArticlesScreen({super.key});

  final List<Map<String, String>> articles = [
    {
      'title': 'Depression',
      'description': 'Learn about the symptoms, causes, and treatments for depression.',
      'url': 'https://www.mayoclinic.org/diseases-conditions/depression/symptoms-causes/syc-20356007',
    },
    {
      'title': 'ADHD',
      'description': 'Understand Attention-Deficit/Hyperactivity Disorder and its management.',
      'url': 'https://chadd.org/about-adhd/overview/',
    },
    {
      'title': 'OCD',
      'description': 'Explore Obsessive-Compulsive Disorder and available support options.',
      'url': 'https://iocdf.org/about-ocd/',
    },
    {
      'title': 'Anxiety',
      'description': 'Discover information on anxiety disorders and coping strategies.',
      'url': 'https://www.nimh.nih.gov/health/topics/anxiety-disorders',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'Articles and FAQs',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () => HomeScreen.launchURL(context, Uri.parse(article['url']!)),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFA3C6C4).withValues(alpha: 0.9),
                        const Color(0xFFF9E8E8).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF333333).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.article,
                          color: Color(0xFF333333),
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['title']!,
                                style: GoogleFonts.lora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article['description']!,
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Color(0xFF333333).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF333333),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}