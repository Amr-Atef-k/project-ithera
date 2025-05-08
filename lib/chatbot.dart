import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatbot extends StatefulWidget {
  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  List<Map<String, String>> messages = [
    {'text': 'How are you feeling today?', 'isUser': 'false'}
  ];
  String? selectedMood;

  final List<String> moodOptions = [
    'Sad',
    'Anxious',
    'Overwhelmed',
    'Stressed',
    'Lonely',
  ];

  final Map<String, Map<String, String>> followUpQuestions = {
    'Sad': {
      'Would you like tips to feel better?': 'Try engaging in activities you enjoy, like listening to music, watching a favorite show, or taking a walk in nature. Talking to a friend or journaling your feelings can also help. If sadness persists, consider reaching out to a professional for support.',
      'Do you want to talk about why you’re sad?': 'I’m here to listen. If you’d like, you can share what’s been making you sad. Sometimes, just talking about it can help. If you’re not ready, that’s okay—maybe try a small, comforting activity like having a warm drink.'
    },
    'Anxious': {
      'Why do I feel anxious all the time?': 'Feeling anxious often can be due to stress, uncertainty, or an underlying anxiety disorder. Try deep breathing: inhale for 4 seconds, hold for 4, and exhale for 4. Writing down your worries can also help clear your mind. If this continues, a therapist can provide more tools to manage anxiety.',
      'What can I do to feel calmer?': 'Let’s try a quick calming technique: close your eyes, take 5 deep breaths, and focus on the air moving in and out. You can also imagine a peaceful place, like a beach or forest. If you’d like, a short meditation or stretching can help too.'
    },
    'Overwhelmed': {
      'What can I do when I feel overwhelmed?': 'When overwhelmed, take a moment to breathe slowly and prioritize one task at a time. Break things into smaller steps, and don’t hesitate to take a short break—maybe a 5-minute stretch or a glass of water. Asking for help from someone you trust can also lighten the load.',
      'How can I manage my tasks better?': 'Start by making a list of what you need to do, then pick the most important task to focus on first. Set a timer for 25 minutes to work on it (this is called the Pomodoro technique), then take a 5-minute break. Small steps can make things feel more manageable.'
    },
    'Stressed': {
      'How can I calm down when I’m stressed?': 'To calm stress, try a quick relaxation technique: close your eyes, take 5 deep breaths, and focus on the air moving in and out. You can also try progressive muscle relaxation—tense and release each muscle group. A short walk or listening to calming music can also help.',
      'What’s a quick way to reduce stress?': 'A quick way to reduce stress is to do a 1-minute breathing exercise: inhale deeply through your nose for 4 seconds, hold for 4, and exhale through your mouth for 4. Repeat a few times. You can also try stretching your shoulders or listening to a calming song.'
    },
    'Lonely': {
      'I feel lonely, what should I do?': 'Feeling lonely can be tough, but small steps can help. Reach out to a friend or family member for a chat, even if it’s just a quick text. Joining a club or online community with shared interests can also create connections. If loneliness persists, talking to a counselor might help.',
      'How can I feel more connected?': 'Try reaching out to someone you trust, even with a simple message like “Hey, how are you?” You can also explore online groups or forums related to hobbies you enjoy. Sometimes, even small interactions—like chatting with a neighbor—can make a difference.'
    },
  };

  bool get _showWelcomeText => messages.length == 1 && messages[0]['text'] == 'How are you feeling today?' && selectedMood == null;

  void _selectMood(String mood) {
    setState(() {
      selectedMood = mood;
      messages.insert(0, {'text': 'I’m feeling $mood.', 'isUser': 'true'});
      messages.insert(0, {'text': 'I’m here to help with feeling $mood.', 'isUser': 'false'});
    });
  }

  void _askFollowUp(String question) {
    setState(() {
      messages.insert(0, {'text': question, 'isUser': 'true'});
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        messages.insert(0, {
          'text': followUpQuestions[selectedMood!]![question]!,
          'isUser': 'false'
        });
      });
    });
  }

  void _goBackToMoodSelection() {
    setState(() {
      selectedMood = null;
      messages.insert(0, {'text': 'How are you feeling today?', 'isUser': 'false'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'Chatbot',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF333333),
                  width: 1.0,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/avatar.png'),
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          if (_showWelcomeText)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Welcome, how can I help you today?',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = messages[index]['isUser'] == 'true';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: isUserMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? const Color(0xFFA3C6C4)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AnimatedText(
                          key: ValueKey('${messages[index]['text']}_$index'),
                          text: messages[index]['text']!,
                          isAnswer: !isUserMessage && index == 0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFA3C6C4),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white.withOpacity(0.9),
              ),
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: selectedMood == null
                    ? moodOptions.map((mood) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () => _selectMood(mood),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3C6C4),
                        foregroundColor: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        mood,
                        style: GoogleFonts.roboto(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList()
                    : [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: _goBackToMoodSelection,
                          icon: Icon(
                            Icons.arrow_back,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...followUpQuestions[selectedMood!]!.keys.map((question) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        onPressed: () => _askFollowUp(question),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA3C6C4),
                          foregroundColor: const Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          question,
                          style: GoogleFonts.roboto(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  final String text;
  final bool isAnswer;

  AnimatedText({required this.text, required this.isAnswer, Key? key})
      : super(key: key);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String displayText = '';
  int textIndex = 0;
  Timer? _timer;
  bool hasAnimated = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAnswer && !hasAnimated) {
      _animateText();
    } else {
      displayText = widget.text;
    }
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        displayText = '';
        textIndex = 0;
        hasAnimated = false;
      });
      _timer?.cancel();
      if (widget.isAnswer && !hasAnimated) {
        _animateText();
      } else {
        setState(() {
          displayText = widget.text;
        });
      }
    }
  }

  void _animateText() {
    hasAnimated = true;
    _timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (textIndex < widget.text.length) {
        setState(() {
          displayText += widget.text[textIndex];
          textIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayText,
      style: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF333333),
      ),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}