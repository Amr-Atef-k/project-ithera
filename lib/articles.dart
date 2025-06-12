import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ArticleViewerScreen to display article in a WebView
class ArticleViewerScreen extends StatefulWidget {
  final String articleUrl;
  final String articleTitle;

  const ArticleViewerScreen({
    super.key,
    required this.articleUrl,
    required this.articleTitle,
  });

  @override
  ArticleViewerScreenState createState() => ArticleViewerScreenState();
}

class ArticleViewerScreenState extends State<ArticleViewerScreen> {
  late WebViewController _controller;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF9E8E8))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true; // Show loading when page starts
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // Hide loading when page finishes
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false; // Hide loading on error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load article. Please check your connection.',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFF333333),
                duration: const Duration(seconds: 4),
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.articleUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          widget.articleTitle,
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF9E8E8).withOpacity(0.8),
        child: Stack(
          children: [
            // WebView content
            WebViewWidget(controller: _controller),
            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA3C6C4)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Define the ArticlesScreen widget as a stateless widget
class ArticlesScreen extends StatelessWidget {
  // Constructor with an optional key parameter
  const ArticlesScreen({super.key});

  // List of articles with title, description, and URL
  final List<Map<String, String>> articles = const [
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
    {
      'title': 'Bipolar Disorder',
      'description': 'Understand the symptoms and treatment options for bipolar disorder.',
      'url': 'https://www.nimh.nih.gov/health/topics/bipolar-disorder',
    },
    {
      'title': 'Post-Traumatic Stress Disorder (PTSD)',
      'description': 'Learn about PTSD, its causes, and how to seek help.',
      'url': 'https://www.ptsd.va.gov/understand/what/index.asp',
    },
    {
      'title': 'Eating Disorders',
      'description': 'Explore types of eating disorders and available treatments.',
      'url': 'https://www.nationaleatingdisorders.org/what-are-eating-disorders',
    },
    {
      'title': 'Schizophrenia',
      'description': 'Find out about schizophrenia symptoms, causes, and support.',
      'url': 'https://www.nimh.nih.gov/health/topics/schizophrenia',
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
                // Navigate to ArticleViewerScreen when tapped
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleViewerScreen(
                        articleUrl: article['url']!,
                        articleTitle: article['title']!,
                      ),
                    ),
                  );
                },
                // Set border radius for tap effect
                borderRadius: BorderRadius.circular(16),
                // Animated container for visual effects
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  // Define the container decoration
                  decoration: BoxDecoration(
                    // Gradient background
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFA3C6C4),
                        Color(0xFFF9E8E8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // Rounded corners
                    borderRadius: BorderRadius.circular(16),
                    // Shadow effect
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    // Border styling
                    border: Border.all(
                      color: Color(0xFF333333).withOpacity(0.2),
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
                                  color: Color(0xFF333333),
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