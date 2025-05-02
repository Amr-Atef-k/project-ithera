import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isBreathingIn = true;
  bool isSessionActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5), // 5s for inhale and exhale
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleBreathingSession() {
    setState(() {
      isSessionActive = !isSessionActive;
      if (isSessionActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
        isBreathingIn = true;
      }
    });
  }

  Stream<int> countdownTimer() async* {
    const int phaseDuration = 5;
    int seconds = phaseDuration;
    while (true) {
      yield seconds;
      await Future.delayed(const Duration(seconds: 1));
      if (isSessionActive) {
        seconds--;
        if (seconds == 0) {
          seconds = phaseDuration;
        }
      } else {
        seconds = phaseDuration;
      }
    }
  }

  Stream<bool> breathingPhase() async* {
    while (true) {
      if (isSessionActive) {
        yield true; // Inhale: outward (0.5 to 1.0)
        await Future.delayed(const Duration(seconds: 5));
        yield false; // Exhale: inward (1.0 to 0.5)
        await Future.delayed(const Duration(seconds: 5));
      } else {
        yield true;
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'Breathing Exercise',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF9E8E8).withOpacity(0.9),
              const Color(0xFFA3C6C4).withOpacity(0.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200 * (isSessionActive ? _animation.value : 0.5),
                            height: 200 * (isSessionActive ? _animation.value : 0.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.5),
                                  Colors.green.withOpacity(0.2),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -30.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: StreamBuilder<int>(
                        stream: countdownTimer(),
                        initialData: 5,
                        builder: (context, snapshot) {
                          return Text(
                            '${snapshot.data}s',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFF333333),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: StreamBuilder<bool>(
                        stream: breathingPhase(),
                        initialData: true,
                        builder: (context, snapshot) {
                          isBreathingIn = snapshot.data ?? true;
                          return Text(
                            isBreathingIn ? 'Breathe in...' : 'Breathe out...',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFF333333),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        onPressed: toggleBreathingSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA3C6C4),
                          foregroundColor: const Color(0xFF333333),
                          shape: const CircleBorder(),
                          minimumSize: const Size(60, 60),
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Icon(
                          isSessionActive ? Icons.stop : Icons.play_arrow,
                          size: 30,
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
      ),
    );
  }
}