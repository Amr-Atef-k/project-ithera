import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatbot extends StatefulWidget {
  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  List<Map<String, String>> messages = [
    {'text': 'How can I help you?', 'isUser': 'false'}
  ];
  String? selectedCategory;
  String? selectedSubOption;

  // Track which messages have been animated
  final Map<String, bool> _animatedMessages = {};

  final List<String> categoryOptions = [
    'I need help with ...',
    'I want to learn about ...',
    'I’d like tips for ...',
    'I’m struggling with ...',
    'I want to try ...',
  ];

  final Map<String, List<String>> subOptions = {
    'I need help with ...': [
      'Managing stress',
      'Improving focus',
      'Getting motivated',
      'Sleeping better',
      'Building confidence',
    ],
    'I want to learn about ...': [
      'Mindfulness techniques',
      'Self-care practices',
      'Coping with change',
      'Building resilience',
      'Healthy relationships',
    ],
    'I’d like tips for ...': [
      'Starting my day positively',
      'Handling tough conversations',
      'Staying calm under pressure',
      'Boosting my mood',
      'Organizing my tasks',
    ],
    'I’m struggling with ...': [
      'School pressures',
      'Work stress',
      'Relationship issues',
      'Low energy',
      'Negative thoughts',
    ],
    'I want to try ...': [
      'A relaxation exercise',
      'A journaling prompt',
      'A gratitude practice',
      'A breathing technique',
      'A small goal-setting activity',
    ],
  };

  final Map<String, Map<String, String>> responses = {
    'Managing stress': {
      'response': 'Stress can feel overwhelming, but there are many strategies to manage it effectively. Start with a deep breathing exercise: inhale for 4 seconds, hold for 4, exhale for 4, and repeat for 2 minutes to calm your nervous system. Physical activity, like a 20-minute walk, yoga, or dancing, releases tension and boosts endorphins, helping you feel more grounded. Journaling for 10-15 minutes about what’s stressing you can clarify your thoughts and reduce mental clutter. Prioritize tasks by creating a to-do list, focusing on the top three items to avoid feeling swamped. Ensure you’re getting 7-8 hours of sleep and staying hydrated, as these support stress resilience. Lastly, try a 5-minute mindfulness practice, like focusing on sounds around you, to stay present. You’re taking a great step by addressing stress, and these tools can help you feel more in control.'
    },
    'Improving focus': {
      'response': 'Improving focus takes practice, but you can build this skill with consistent strategies. Create a distraction-free environment: turn off notifications, use noise-canceling headphones, or choose a quiet workspace. Try the Pomodoro technique—work for 25 minutes, then take a 5-minute break—to maintain concentration without burnout. Apps like Forest or Focus@Will can keep you engaged. Break tasks into smaller, manageable chunks to make them less daunting, and start with the easiest one to build momentum. Stay hydrated and eat brain-boosting snacks like nuts or fruit to sustain energy. A 5-minute mindfulness exercise, like focusing on your breath, can help center your mind before starting work. Schedule short movement breaks, like stretching, to refresh your brain. You’re capable of great focus, and these steps will help you harness it.'
    },
    'Getting motivated': {
      'response': 'Finding motivation can be tough, but small, intentional steps can spark momentum. Set a tiny, achievable goal, like working on a task for just 10 minutes, to overcome inertia. Reward yourself afterward with something enjoyable, like a favorite snack or a quick episode of a show. Visualize the benefits of completing the task—how will it feel to check it off? Create a motivating environment by playing upbeat music or tidying your workspace. Break larger goals into bite-sized steps to make them feel less overwhelming. Share your goal with a friend for accountability, or use apps like Habitica to gamify progress. If you’re stuck, try a 2-minute gratitude practice to shift your mindset. Your motivation is there, and these strategies can help you tap into it.'
    },
    'Sleeping better': {
      'response': 'Good sleep is crucial for your well-being, and a consistent routine can improve it. Create a calming bedtime ritual: avoid screens 1 hour before bed, as blue light disrupts melatonin. Instead, read a book, listen to soothing music, or try gentle stretches. Keep your bedroom cool, dark, and quiet, and invest in comfortable bedding if possible. Stick to a regular sleep schedule, even on weekends, to regulate your body clock. Limit caffeine after noon and avoid heavy meals close to bedtime. A 5-minute relaxation exercise, like progressive muscle relaxation (tensing and releasing each muscle group), can ease you into sleep. Journaling worries before bed can clear your mind. If you can’t sleep, get up briefly and do something calm, like sipping herbal tea. You deserve restful sleep, and these habits can help.'
    },
    'Building confidence': {
      'response': 'Building confidence is a journey, and you can grow it with practical steps. Start by setting small, achievable goals, like speaking up once in a meeting or trying a new hobby, to build a sense of accomplishment. Practice positive affirmations daily—write three things you like about yourself and say them aloud. Reflect on past successes, no matter how small, to remind yourself of your capabilities. Surround yourself with supportive people who uplift you, and limit time with those who don’t. Try power posing: stand tall with hands on hips for 2 minutes to boost your mood. Learn a new skill through online courses or tutorials to expand your abilities. Accept compliments graciously, and challenge self-doubt by writing evidence of your strengths. You’re stronger than you know, and these steps will help you shine.'
    },
    'Mindfulness techniques': {
      'response': 'Mindfulness helps you stay present and reduce mental clutter, and there are many ways to practice it. Start with a 5-minute meditation: sit comfortably, close your eyes, and focus on your breath, noticing each inhale and exhale. If your mind wanders, gently bring it back. Try a body scan meditation, where you focus on each part of your body from toes to head, releasing tension. Practice mindful eating by savoring each bite of a meal, noticing flavors and textures. Use apps like Headspace or Calm for guided sessions. Incorporate mindfulness into daily tasks, like washing dishes while focusing on the water’s warmth. Set reminders to pause and take 3 deep breaths throughout the day. Journaling about your experiences can deepen your practice. Mindfulness is a skill you’re building, and it can bring calm to your life.'
    },
    'Self-care practices': {
      'response': 'Self-care is about nurturing your mind and body, and a variety of practices can recharge you. Schedule 30 minutes daily for an activity you love, like reading, painting, or gardening, to boost your mood. Take a warm bath with essential oils or listen to a calming playlist to relax. Prioritize nutrition by preparing a balanced meal, like a colorful salad, to fuel your body. Move your body daily—try a 15-minute walk, yoga, or dancing to release stress. Connect with a friend or family member, even via a quick call, to feel supported. Set boundaries by saying “no” to tasks that drain you. Try a 5-minute gratitude practice, listing things you appreciate. Track your self-care habits in a journal to stay consistent. You deserve this care, and it will help you thrive.'
    },
    'Coping with change': {
      'response': 'Change can be challenging, but you can navigate it with resilience. Break the change into smaller steps—focus on one aspect at a time, like adjusting to a new routine by setting a daily schedule. Write down what you can control (e.g., your attitude) and let go of what you can’t. Talk to a trusted friend or journal about your feelings to process them. Practice self-compassion by reminding yourself it’s okay to feel unsettled. Establish anchors, like a morning coffee ritual, to maintain stability. Try a 5-minute mindfulness exercise, focusing on sounds around you, to stay grounded. Reflect on past changes you’ve overcome to boost confidence. Stay flexible by exploring new opportunities the change might bring. You’re adaptable, and these strategies will guide you through.'
    },
    'Building resilience': {
      'response': 'Resilience helps you bounce back from challenges, and you can strengthen it over time. Reflect on past successes—write down three times you overcame obstacles and what you learned. Practice self-compassion by speaking to yourself kindly, as you would a friend. Build a support network by connecting regularly with friends, family, or a mentor. Set realistic goals, like completing a small task daily, to build confidence. Stay physically active with 20 minutes of exercise, like walking or cycling, to boost mood. Try a gratitude journal, noting three things each day that went well. Learn from setbacks by asking, “What can I do differently next time?” Use mindfulness apps to practice staying present during tough moments. You’re resilient, and these habits will make you stronger.'
    },
    'Healthy relationships': {
      'response': 'Healthy relationships are built on trust and communication, and you can nurture them with intention. Practice active listening—give your full attention, nod, and reflect back what you hear. Use “I” statements, like “I feel upset when…,” to express needs without blame. Set clear boundaries, like needing personal time, and communicate them calmly. Schedule quality time, like a coffee date or shared hobby, to strengthen bonds. Show appreciation by noting small things you value, like a kind gesture. Resolve conflicts by staying calm, taking breaks if needed, and focusing on solutions. Check in regularly with loved ones to stay connected. If a relationship feels unhealthy, seek advice from a trusted person. You deserve fulfilling connections, and these steps will help you build them.'
    },
    'Starting my day positively': {
      'response': 'A positive morning sets the tone for your day, and small habits can make a big difference. Begin with 5 minutes of stretching or gentle yoga to wake your body. Write down three things you’re looking forward to today, no matter how small, to spark optimism. Eat a nourishing breakfast, like oatmeal with fruit, to fuel your energy. Listen to uplifting music or a motivational podcast while getting ready. Avoid checking your phone first thing—instead, spend 2 minutes breathing deeply to center yourself. Set one intention for the day, like “I’ll be kind to myself.” If time allows, spend 10 minutes on a hobby, like sketching or reading. Tidy one small space, like your desk, for a sense of control. You’re starting strong, and these routines will lift your day.'
    },
    'Handling tough conversations': {
      'response': 'Tough conversations are hard, but preparation and calm can make them productive. Before the talk, clarify your goal—do you want understanding or a solution? Use “I” statements, like “I feel concerned when…,” to express yourself without blame. Practice active listening: nod, maintain eye contact, and paraphrase to show you understand. Stay calm by taking slow breaths if emotions rise; if needed, suggest a short break. Choose a private, neutral setting and a time when both parties are relaxed. Prepare for different responses by thinking through possible reactions. Follow up later to check in, showing you value the relationship. Write down key points beforehand to stay focused. You’re capable of navigating this, and these strategies will guide you.'
    },
    'Staying calm under pressure': {
      'response': 'Staying calm under pressure is a skill you can develop with practice. Take slow, deep breaths—inhale for 4, exhale for 6—to lower your heart rate. Focus on one task at a time; write down others to clear your mind. Use a grounding technique, like naming 5 things you see, to stay present. Take a 2-minute break to stretch or sip water, resetting your mind. Reframe pressure as a challenge: ask, “What’s one step I can take now?” Stay hydrated and avoid excessive caffeine, which can heighten anxiety. Practice positive self-talk, like “I’ve handled tough moments before.” If possible, step outside for fresh air to shift your perspective. You’re stronger than the pressure, and these tools will keep you steady.'
    },
    'Boosting my mood': {
      'response': 'Lifting your mood can start with small, intentional actions. Step outside for a 10-minute walk to get fresh air and sunlight, which boosts serotonin. Listen to an upbeat playlist or watch a funny video for a quick laugh. Connect with a friend, even via a text, to feel supported. Try a 5-minute gratitude practice: write down three things that brought you joy today. Engage in a creative activity, like doodling or cooking, to express yourself. Eat a healthy snack, like fruit or dark chocolate, to stabilize energy. Move your body with a quick dance or stretch session to release endorphins. If you’re indoors, open a window or light a candle for a cozy vibe. Your mood is worth nurturing, and these steps will help.'
    },
    'Organizing my tasks': {
      'response': 'Organizing tasks can reduce overwhelm and boost productivity. Start with a brain dump: write down every task on your mind, no matter how small. Categorize them into “urgent,” “important,” and “later” using a tool like a notebook or app (e.g., Todoist). Pick your top three priorities for the day and focus on those first. Use the Pomodoro technique—25 minutes of work, 5-minute break—to stay on track. Break large tasks into smaller steps; for example, “write report” becomes “outline, draft, edit.” Set specific deadlines, like “finish X by 3 PM.” Keep your workspace tidy to minimize distractions. Review your list at day’s end to plan tomorrow. Celebrate small wins, like checking off one task. You’re in control, and this system will keep you organized.'
    },
    'School pressures': {
      'response': 'School pressures can feel heavy, but you can manage them with structure and self-care. Create a study schedule, allocating specific times for each subject, and stick to it to avoid cramming. Break assignments into smaller tasks—start with a 10-minute outline to build momentum. Use a planner or app like Notion to track deadlines. Take regular breaks: study for 25 minutes, then stretch for 5 to stay fresh. Connect with a teacher or classmate for support if you’re stuck. Prioritize sleep (7-8 hours) and healthy snacks, like nuts, to maintain energy. Try a 2-minute breathing exercise before studying to calm nerves. Limit multitasking—focus on one subject at a time. You’re doing your best, and these strategies will ease the pressure.'
    },
    'Work stress': {
      'response': 'Work stress can pile up, but you can tackle it with practical steps. Start by prioritizing tasks: list your top three must-dos each day and tackle them first. Use the Pomodoro technique—25 minutes of focused work, 5-minute break—to stay productive without burnout. Set boundaries, like avoiding work emails after hours, to protect your personal time. Take 2-minute movement breaks, like stretching, to reset your mind. Stay hydrated and eat balanced meals to sustain energy. Communicate with your manager or team if workloads feel unmanageable—honesty can lead to solutions. Try a 5-minute mindfulness practice, focusing on your breath, to reduce tension. Reflect on what you’ve accomplished each day to feel progress. You’re navigating work well, and these tools will help.'
    },
    'Relationship issues': {
      'response': 'Relationship issues can weigh heavily, but thoughtful steps can improve things. Start with an open, calm conversation—use “I” statements like “I feel hurt when…” to share your perspective without blame. Listen actively, reflecting back what you hear to show understanding. Set clear boundaries, like needing time alone, and communicate them kindly. Schedule quality time, like a walk or shared meal, to rebuild connection. If emotions run high, take a 10-minute break to cool off before continuing. Journal your feelings to gain clarity before talking. Seek a neutral perspective from a trusted friend if you’re unsure. Practice self-care, like a 5-minute meditation, to stay grounded. Your relationships matter, and these steps can foster healing.'
    },
    'Low energy': {
      'response': 'Low energy can make everything harder, but you can boost it with small changes. Start with a 10-minute walk or light stretching to increase blood flow and wake your body. Eat energy-boosting snacks, like a banana with peanut butter or yogurt with berries, to stabilize blood sugar. Stay hydrated—aim for 8 glasses of water daily, as dehydration saps energy. Check your sleep: aim for 7-8 hours and keep a consistent bedtime. Take short power naps (10-20 minutes) if needed, but avoid long naps that disrupt nighttime sleep. Try a 2-minute breathing exercise to oxygenate your body. Limit caffeine late in the day to avoid crashes. Spend 5 minutes on a fun activity, like listening to music, to lift your spirits. Your energy will rebound with these habits.'
    },
    'Negative thoughts': {
      'response': 'Negative thoughts can be persistent, but you can challenge them with practice. Write down the thought, then list evidence that contradicts it—e.g., if you think “I always fail,” note past successes. Practice a 5-minute gratitude exercise: write three things you’re thankful for to shift focus. Use cognitive reframing: turn “I’m terrible at this” into “I’m learning, and that’s okay.” Limit exposure to negative triggers, like certain social media, and curate positive content. Talk to a friend or journal to externalize thoughts. Try mindfulness: focus on your breath for 2 minutes to create space from thoughts. Replace self-criticism with self-compassion, like “I’m doing my best.” Exercise, even a 10-minute walk, can clear your mind. You’re stronger than these thoughts, and these tools will help.'
    },
    'A relaxation exercise': {
      'response': 'Relaxation exercises can melt tension, and here’s one to try. Find a quiet spot, sit or lie down, and close your eyes. Take 5 slow, deep breaths, inhaling for 4, exhaling for 6. Imagine a peaceful place—like a beach or forest—and picture the details: the sounds, smells, and colors. Spend 2 minutes visualizing this scene, letting your body soften. Next, try progressive muscle relaxation: starting from your toes, tense each muscle group for 5 seconds, then release, moving up to your head over 3 minutes. End with a full-body scan, noticing any remaining tension and letting it go. Journal how you feel afterward to track benefits. Practice this daily for deeper calm. You’re giving yourself a gift with this exercise.'
    },
    'A journaling prompt': {
      'response': 'Journaling can unlock insights, and here’s a meaningful prompt to try. Write for 10-15 minutes about a moment you felt truly proud of yourself—describe what happened, why it mattered, and how it made you feel. Reflect on what strengths you showed and how you can use them now. If emotions arise, let them flow without judgment. Use a notebook or app like Day One, and find a quiet space to focus. Set a timer to stay engaged, and play soft music if it helps. After writing, read your entry and highlight one positive insight. Try journaling daily with different prompts, like “What’s one thing I learned today?” This practice builds self-awareness, and you’re doing great by starting.'
    },
    'A gratitude practice': {
      'response': 'Gratitude can shift your perspective, and here’s a practice to try. Each day, write down 3-5 things you’re grateful for, from small moments (a warm coffee) to big ones (a supportive friend). Use a journal or app like Grateful, and spend 5-10 minutes reflecting on why these things matter. For deeper impact, say them aloud or share one with someone. Try this at the same time daily, like before bed, to build a habit. If you’re struggling, start with basics, like having a safe place to rest. Pair it with a 2-minute breathing exercise to stay present. Over time, notice how your mindset shifts. Keep a gratitude jar—add notes daily and read them monthly for a mood boost. You’re cultivating joy with this practice.'
    },
    'A breathing technique': {
      'response': 'Breathing techniques can calm your mind, and box breathing is a great one to try. Sit comfortably, close your eyes, and inhale for 4 seconds, hold for 4, exhale for 4, hold for 4. Repeat for 2-3 minutes, focusing on the rhythm. Visualize a square as you breathe to stay engaged. Practice this twice daily—morning and evening—or when stress rises. If 4 seconds feels tough, start with 3 and build up. Use apps like Breathwrk for guided practice. Pair it with a grounding exercise: notice your feet on the floor to stay present. Journal how you feel after each session to track progress. If dizziness occurs, shorten the holds. You’re nurturing calm with this technique, and it’s a powerful tool.'
    },
    'A small goal-setting activity': {
      'response': 'Setting small goals builds momentum, and here’s an activity to try. Pick one achievable goal for today, like drinking 2 extra glasses of water, tidying your desk, or reading for 10 minutes. Write it down in a planner or app like Todoist, and note why it matters (e.g., “I’ll feel refreshed”). Break it into steps if needed—e.g., for tidying, start with one corner. Set a specific time to do it, like “after lunch.” Reward yourself after, like with a favorite song or snack. Reflect afterward: write 2 sentences about how it felt to complete it. Build on this by adding one goal daily, keeping them small to avoid overwhelm. Track progress weekly to see growth. You’re taking charge with this activity, and it’s a great start.'
    },
  };

  bool get _showWelcomeText => messages.length == 1 && messages[0]['text'] == 'How can I help you?' && selectedCategory == null;

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      messages.insert(0, {'text': category, 'isUser': 'true'});
      String intermediateResponse;
      switch (category) {
        case 'I need help with ...':
          intermediateResponse = 'What do you need help with?';
          break;
        case 'I want to learn about ...':
          intermediateResponse = 'What would you like to learn about?';
          break;
        case 'I’d like tips for ...':
          intermediateResponse = 'What tips are you looking for?';
          break;
        case 'I’m struggling with ...':
          intermediateResponse = 'What are you struggling with?';
          break;
        case 'I want to try ...':
          intermediateResponse = 'What would you like to try?';
          break;
        default:
          intermediateResponse = '';
      }
      if (intermediateResponse.isNotEmpty) {
        messages.insert(0, {
          'text': intermediateResponse,
          'isUser': 'false'
        });
      }
    });
  }

  void _selectSubOption(String option) {
    setState(() {
      selectedSubOption = option;
      messages.insert(0, {'text': option, 'isUser': 'true'});
      messages.insert(0, {
        'text': responses[option]!['response']!,
        'isUser': 'false'
      });
    });
  }

  void _goBackToCategorySelection() {
    setState(() {
      selectedCategory = null;
      selectedSubOption = null;
      messages.insert(0, {'text': 'How can I help you?', 'isUser': 'false'});
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
                backgroundImage: AssetImage('assets/logo.png'),
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
                          hasAnimated: _animatedMessages['${messages[index]['text']}_$index'] ?? false,
                          onAnimationComplete: () {
                            setState(() {
                              _animatedMessages['${messages[index]['text']}_$index'] = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              height: 200,
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
                children: selectedCategory == null
                    ? categoryOptions.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () => _selectCategory(category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3C6C4),
                        foregroundColor: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        category,
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
                          onPressed: _goBackToCategorySelection,
                          icon: Icon(
                            Icons.arrow_back,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...subOptions[selectedCategory!]!.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        onPressed: () => _selectSubOption(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA3C6C4),
                          foregroundColor: const Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          option,
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
  final bool hasAnimated;
  final VoidCallback onAnimationComplete;

  AnimatedText({
    required this.text,
    required this.isAnswer,
    required this.hasAnimated,
    required this.onAnimationComplete,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String displayText = '';
  int textIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isAnswer && !widget.hasAnimated) {
      _animateText();
    } else {
      displayText = widget.text;
    }
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && widget.isAnswer && !widget.hasAnimated) {
      setState(() {
        displayText = '';
        textIndex = 0;
      });
      _timer?.cancel();
      _animateText();
    } else if (oldWidget.text != widget.text) {
      setState(() {
        displayText = widget.text;
      });
    }
  }

  void _animateText() {
    _timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (textIndex < widget.text.length) {
        setState(() {
          displayText += widget.text[textIndex];
          textIndex++;
        });
      } else {
        timer.cancel();
        widget.onAnimationComplete();
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