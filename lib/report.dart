import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

// Displays the final test results with score, message, and highest emotion
class ReportScreen extends StatelessWidget {
  final int score;
  final String resultMessage;
  final String highestEmotion;
  final int highestEmotionPercentage;

  const ReportScreen({
    required this.score,
    required this.resultMessage,
    required this.highestEmotion,
    required this.highestEmotionPercentage,
    super.key,
  });

  // Splits the result message into condition and suggested actions
  List<String> _splitMessage(String message) {
    return message.split('\n\n**Suggested Actions:**');
  }

  // Builds RichText with red highlights for key condition words
  RichText _buildConditionText(String condition) {
    final wordsToHighlight = [
      'stable',
      'mild',
      'moderate',
      'significant',
      'distress',
      'anxiety',
      'depression',
      'stress',
      'sadness',
      'hopelessness',
      'overwhelmed',
      'disconnected',
    ];
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\b\w+\b');
    int lastIndex = 0;

    for (var match in exp.allMatches(condition)) {
      String word = match.group(0)!;
      int start = match.start;
      int end = match.end;

      // Add text before the word
      if (start > lastIndex) {
        spans.add(TextSpan(
          text: condition.substring(lastIndex, start),
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: const Color(0xFF333333),
          ),
        ));
      }

      // Add the word, red if it’s in the highlight list
      spans.add(TextSpan(
        text: word,
        style: GoogleFonts.roboto(
          fontSize: 16,
          color: wordsToHighlight.contains(word.toLowerCase())
              ? const Color(0xFFE57373)
              : const Color(0xFF333333),
        ),
      ));

      lastIndex = end;
    }

    // Add remaining text
    if (lastIndex < condition.length) {
      spans.add(TextSpan(
        text: condition.substring(lastIndex),
        style: GoogleFonts.roboto(
          fontSize: 16,
          color: const Color(0xFF333333),
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageParts = _splitMessage(resultMessage);
    final condition = messageParts[0];
    final suggestedActions = messageParts.length > 1 ? messageParts[1] : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'Test Results',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Score Section
                      Text(
                        'Your Score',
                        style: GoogleFonts.lora(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score',
                        style: GoogleFonts.roboto(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFA3C6C4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFA3C6C4)),
                      // Highest Emotion Section
                      Text(
                        'Dominant Emotion',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$highestEmotion ($highestEmotionPercentage%)',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFA3C6C4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFA3C6C4)),
                      // Assessment Section
                      Text(
                        'Assessment',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildConditionText(condition),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFA3C6C4)),
                      // Suggested Actions Section
                      Text(
                        'Recommended Actions',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        suggestedActions,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: const Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Back to Home Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA3C6C4),
                          foregroundColor: const Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Back to Home',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}