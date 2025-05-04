import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart'; // Import HomeScreen for launchURL

class VideosScreen extends StatelessWidget {
  VideosScreen({super.key});

  // List of videos with title, YouTube URL, and thumbnail asset path
  final List<Map<String, String>> videos = [
    {
      'title': 'Guided Meditation for Anxiety',
      'url': 'https://www.youtube.com/watch?v=O-6f5wQXSu8',
      'thumbnail': 'assets/1.jpg',
    },
    {
      'title': 'Quick Stress Fix - 5 Minute Sequence',
      'url': 'https://www.youtube.com/watch?v=4pKly2JojMw',
      'thumbnail': 'assets/2.jpg',
    },
    {
      'title': 'Understanding Mindfulness',
      'url': 'https://www.youtube.com/watch?v=w6T02g5hnT4',
      'thumbnail': 'assets/3.jpg',
    },
    {
      'title': 'Breathing Exercises for Relaxation',
      'url': 'https://www.youtube.com/watch?v=aXItOY0sLRY',
      'thumbnail': 'assets/4.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'Online Videos',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF9E8E8).withOpacity(0.8),
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        video['thumbnail']!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      video['title']!,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3C6C4),
                        foregroundColor: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        HomeScreen.launchURL(context, Uri.parse(video['url']!));
                      },
                      child: Text(
                        'Watch Video',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}