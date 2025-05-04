import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'services/user_prefs.dart';
import 'database_helper.dart';
import 'class/report.dart';
import 'report.dart';
import 'home.dart';

// Defines the TestPage widget for the mental health assessment
class TestPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const TestPage({required this.cameras, super.key});

  @override
  _TestPageState createState() => _TestPageState();
}

// State class for TestPage, managing camera, questions, and user answers
class _TestPageState extends State<TestPage> {
  late CameraController _cameraController; // Controls the front-facing camera
  bool _isCameraInitialized = false; // Tracks camera initialization status
  bool _isControllerDisposed = false; // Tracks if camera controller is disposed

  int _currentQuestionIndex = 0; // Tracks the current question being displayed
  List<String?> _selectedAnswers = []; // Stores user-selected answers
  int? _totalScore; // Stores the calculated score after submission
  String? _resultMessage; // Stores the result message based on score
  String? _lastResult; // Stores the last saved result from storage

  final StorageService _storageService = StorageService(); // Service for local storage

  // List of 18 questions to assess mental health
  final List<String> _questions = [
    'How often do you feel depressed or down?',
    'How frequently do you feel anxious or worried?',
    'Do you often feel stressed or overwhelmed?',
    'How often do you have difficulty concentrating?',
    'Do you frequently have trouble sleeping?',
    'How often do you experience physical symptoms like headaches or stomachaches without a medical cause?',
    'How frequently do you feel lonely or isolated?',
    'Do you often engage in activities that you find enjoyable?',
    'How often do you feel confident in your abilities?',
    'Do you frequently feel hopeful about the future?',
    'How often do you feel like you can handle your problems?',
    'Do you often feel satisfied with your life?',
    'How frequently do you experience mood swings?',
    'Do you often feel irritable or angry?',
    'How often do you feel disconnected from others?',
    'Do you frequently lack energy or motivation?',
    'How often do you feel a sense of purpose in your life?',
    'Do you often feel supported by friends or family?',
  ];

  // Indices of positively framed questions (higher frequency = better mental health)
  final List<int> _positiveQuestionIndices = [7, 8, 9, 10, 11, 16, 17];
  // Answer options for each question
  final List<String> _options = ['Rarely', 'Sometimes', 'Often', 'Always'];

  @override
  void initState() {
    super.initState();
    // Initialize answers list with null for all 18 questions
    _selectedAnswers = List<String?>.filled(_questions.length, null);
    // Set up camera for emotion detection
    _initializeCamera();
    // Load the last saved result from storage
    _loadLastResult();
  }

  // Initializes the front-facing camera
  void _initializeCamera() async {
    _cameraController = CameraController(
      widget.cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true; // Update UI once camera is ready
      });
    }
  }

  // Loads the last saved result from storage
  Future<void> _loadLastResult() async {
    final result = await _storageService.getLastResult();
    setState(() {
      _lastResult = result;
    });
  }

  // Saves the current result to storage
  Future<void> _saveResult(String result) async {
    await _storageService.saveLastResult(result);
    setState(() {
      _lastResult = result;
    });
  }

  // Saves the test result to the database
  Future<void> _saveTestResult(int score, String resultMessage) async {
    final userId = await UserPrefs.getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }
    final dbHelper = DatabaseHelper();
    final report = Report(
      userId: userId,
      score: score,
      resultMessage: resultMessage,
      timestamp: DateTime.now().toIso8601String(),
    );
    await dbHelper.insertReport(report);
  }

  // Calculates the total score based on user answers
  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _selectedAnswers.length; i++) {
      if (_selectedAnswers[i] == null) continue; // Skip unanswered questions
      int answerScore;
      if (_positiveQuestionIndices.contains(i)) {
        // Positive questions: higher frequency = lower score
        answerScore = switch (_selectedAnswers[i]) {
          'Rarely' => 3,
          'Sometimes' => 2,
          'Often' => 1,
          'Always' => 0,
          _ => 0,
        };
      } else {
        // Negative questions: higher frequency = higher score
        answerScore = switch (_selectedAnswers[i]) {
          'Rarely' => 0,
          'Sometimes' => 1,
          'Often' => 2,
          'Always' => 3,
          _ => 0,
        };
      }
      score += answerScore;
    }
    return score;
  }

  // Generates a result message based on the total score
  String _getResultMessage(int score) {
    if (score <= 13) {
      return 'Your mental health appears to be in a good state. You likely experience minimal distress and maintain a positive outlook. Continue nurturing your well-being with healthy habits.\n\n**Suggested Actions:** Maintain your current self-care practices, such as regular exercise, balanced nutrition, and social engagement. Consider journaling to reflect on your emotions and sustain your mental resilience.';
    } else if (score <= 27) {
      return 'You may be experiencing mild emotional challenges, such as occasional stress, sadness, or anxiety. These feelings are manageable but could benefit from attention. \n\n**Suggested Actions:** Practice relaxation techniques like deep breathing, meditation, or yoga. Engage in hobbies you enjoy and consider discussing your feelings with a trusted friend or family member to gain perspective.';
    } else if (score <= 40) {
      return 'Moderate levels of negative emotions, such as anxiety, depression, or stress, may be affecting your daily life. You might feel overwhelmed or disconnected at times. \n\n**Suggested Actions:** Seek support from a counselor or therapist to explore these feelings. Establish a routine that includes regular sleep, physical activity, and social interaction. Mindfulness practices can also help manage symptoms.';
    } else {
      return 'Significant emotional distress is indicated, which may include intense anxiety, depression, or feelings of hopelessness. These challenges could be impacting your quality of life. \n\n**Suggested Actions:** Strongly consider consulting a mental health professional for personalized support. Reach out to a support network, such as friends or family, and explore therapy options like cognitive-behavioral therapy (CBT). Prioritize self-care and avoid isolating yourself.';
    }
  }

  // Submits answers, calculates score, and navigates to the report screen
  void _submitAnswers() async {
    _totalScore = _calculateScore();
    _resultMessage = _getResultMessage(_totalScore!);
    _saveResult('Score: $_totalScore\n$_resultMessage');
    try {
      await _saveTestResult(_totalScore!, _resultMessage!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving report: $e')),
      );
    }

    // Mark controller as disposed and update UI
    setState(() {
      _isControllerDisposed = true;
    });

    // Dispose of the camera controller and wait for completion
    await _cameraController.dispose();

    // Navigate to ReportScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReportScreen(
            score: _totalScore!,
            resultMessage: _resultMessage!,
          ),
        ),
      );
    }
  }

  // Shows a confirmation dialog when exiting the test
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Test"),
        content: const Text("Are you sure you want to exit the test?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _isControllerDisposed = true;
              });
              await _cameraController.dispose();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // Alerts the user if no answer is selected
  void _showNoAnswerAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Answer Selected"),
        content: const Text("Please select an answer to continue."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (!_isControllerDisposed) {
      _cameraController.dispose(); // Clean up camera resources
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator until camera is initialized
    if (!_isCameraInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    // Build the main UI for the assessment
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'iThera Assessment',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera preview for emotion detection, only if not disposed
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF333333)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _isControllerDisposed
                    ? Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      'Camera Disposed',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                )
                    : CameraPreview(_cameraController),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Emotion: ______', // Placeholder for emotion detection output
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),
            // Display the current question
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFA3C6C4), width: 1),
              ),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '${_currentQuestionIndex + 1}. $currentQuestion',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display answer options as radio buttons
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFA3C6C4), width: 1),
              ),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: _options.map((option) {
                    return RadioListTile<String>(
                      title: Text(
                        option,
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF333333),
                        ),
                      ),
                      value: option,
                      groupValue: _selectedAnswers[_currentQuestionIndex],
                      activeColor: const Color(0xFFA3C6C4),
                      onChanged: (value) {
                        setState(() {
                          _selectedAnswers[_currentQuestionIndex] = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Navigation buttons (Previous/Next/Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--; // Go to previous question
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Previous",
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ),
                const Spacer(),
                if (_currentQuestionIndex < _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedAnswers[_currentQuestionIndex] == null) {
                        _showNoAnswerAlert(); // Prompt user to select an answer
                      } else {
                        setState(() {
                          _currentQuestionIndex++; // Go to next question
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Next",
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ),
                if (_currentQuestionIndex == _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedAnswers[_currentQuestionIndex] == null) {
                        _showNoAnswerAlert(); // Prompt user to select an answer
                      } else {
                        _submitAnswers(); // Submit answers and show results
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}