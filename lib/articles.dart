// Import the Flutter material design package for UI components
import 'package:flutter/material.dart';
// Import Google Fonts for custom typography
import 'package:google_fonts/google_fonts.dart';
// Import the URL launcher package for opening external links
import 'package:url_launcher/url_launcher.dart';
// Import the HomeScreen to access the launchURL method
import 'home.dart';

// Define the ArticlesScreen widget as a stateless widget
class ArticlesScreen extends StatelessWidget {
  // Constructor with an optional key parameter
  ArticlesScreen({super.key});

  // List of articles with title, description, and URL
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

  // Build method to construct the widget tree
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget
    return Scaffold(
      // Set the background color
      backgroundColor: const Color(0xFFF9E8E8),
      // Define the app bar
      appBar: AppBar(
        // Set the background color
        backgroundColor: const Color(0xFFA3C6C4),
        // Set the foreground color
        foregroundColor: const Color(0xFF333333),
        // Set the title
        title: Text(
          'Articles and FAQs',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Define the body with a padded ListView
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          // Number of items in the list
          itemCount: articles.length,
          // Builder function for each list item
          itemBuilder: (context, index) {
            // Get the article data
            final article = articles[index];
            // Return a padded InkWell for tappable items
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                // Launch the article URL when tapped
                onTap: () => HomeScreen.launchURL(context, Uri.parse(article['url']!)),
                // Set border radius for tap effect
                borderRadius: BorderRadius.circular(16),
                // Animated container for visual effects
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  // Define the container decoration
                  decoration: BoxDecoration(
                    // Gradient background
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFA3C6C4).withValues(alpha: 0.9),
                        const Color(0xFFF9E8E8).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // Rounded corners
                    borderRadius: BorderRadius.circular(16),
                    // Shadow effect
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    // Border styling
                    border: Border.all(
                      color: const Color(0xFF333333).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  // Padding inside the container
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    // Row to layout the article content
                    child: Row(
                      children: [
                        // Article icon
                        const Icon(
                          Icons.article,
                          color: Color(0xFF333333),
                          size: 40,
                        ),
                        // Spacing
                        const SizedBox(width: 16),
                        // Expanded column for title and description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Article title
                              Text(
                                article['title']!,
                                style: GoogleFonts.lora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              // Spacing
                              const SizedBox(height: 8),
                              // Article description
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
                        // Arrow icon
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