import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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
  ImageFormatGroup? _imageFormatGroup; // Stores the image format group

  Interpreter? _interpreter; // TensorFlow Lite interpreter for emotion model
  List<String> _emotionLabels = []; // Stores emotion labels from labels.txt
  String _emotion = '______'; // Stores the predicted emotion
  int _emotionPercentage = 0; // Stores the percentage of the predicted emotion
  Timer? _frameProcessingTimer; // Timer for processing frames
  bool _isProcessingFrame = false; // Prevents overlapping frame processing

  FaceDetector? _faceDetector; // Google ML Kit face detector
  bool _hasFace = false; // Tracks if a face is detected
  Rect? _faceBoundingBox; // Stores the bounding box of the detected face

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
    // Set up camera and emotion detection
    _initializeCamera();
    // Load TensorFlow Lite model and labels
    _loadTFLiteModelAndLabels();
    // Initialize face detector
    _initializeFaceDetector();
    // Load the last saved result from storage
    _loadLastResult();
  }

  // Initializes the Google ML Kit face detector
  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false, // Disable contours for faster processing
        enableLandmarks: false, // Disable landmarks for simplicity
        enableClassification: false, // No need for smile/eye detection
      ),
    );
  }

  // Loads the TensorFlow Lite model and emotion labels
  Future<void> _loadTFLiteModelAndLabels() async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('Model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');

      // Load labels
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _emotionLabels = labelsData
          .split('\n')
          .map((line) => line.trim())
          .where((label) => label.isNotEmpty)
          .map((label) => label.replaceAll(RegExp(r'^\d+\s*'), '')) // Remove leading numbers
          .toList();
      print('Loaded labels: $_emotionLabels');
    } catch (e) {
      print('Error loading model or labels: $e');
      setState(() {
        _emotion = 'Error loading model';
      });
    }
  }

  // Initializes the front-facing camera and starts frame processing
  Future<void> _initializeCamera() async {
    _imageFormatGroup = ImageFormatGroup.jpeg; // Set desired format
    _cameraController = CameraController(
      widget.cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.high,
      imageFormatGroup: _imageFormatGroup, // Use JPEG to avoid YUV issues
    );

    try {
      await _cameraController.initialize();
      await _cameraController.setFocusMode(FocusMode.auto); // Ensure sharp images
      print('Camera initialized with format: ${_imageFormatGroup.toString()}');
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _isCameraInitialized = false;
        _emotion = 'Camera error';
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = true; // Update UI once camera is ready
      });

      // Start processing frames every 500ms (reduced frequency for performance)
      _frameProcessingTimer = Timer.periodic(
        const Duration(milliseconds: 500),
            (_) => _processCameraFrame(),
      );
    }
  }

  // Validates input tensor to detect uniform or low-variance data
  bool _isValidInput(Float32List input) {
    if (input.isEmpty) return false;
    final mean = input.reduce((a, b) => a + b) / input.length;
    final variance =
        input.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
            input.length;
    print('Input tensor mean: $mean, variance: $variance');
    return variance > 0.01; // Arbitrary threshold for sufficient variation
  }

  // Processes a single camera frame for face and emotion detection
  Future<void> _processCameraFrame() async {
    if (_isProcessingFrame || _isControllerDisposed || !mounted || !_isCameraInitialized) {
      print('Skipping frame: Processing=${_isProcessingFrame}, Disposed=${_isControllerDisposed}, Mounted=$mounted, Initialized=${_isCameraInitialized}');
      return;
    }

    _isProcessingFrame = true;
    final startTime = DateTime.now(); // Track processing time
    try {
      // Timeout to prevent hangs
      await Future.any([
        Future(() async {
          final image = await _cameraController.takePicture();
          final bytes = await image.readAsBytes();

          // Save frame for inspection (optional, can be commented out in production)
          try {
            await File('/sdcard/sample_frame.jpg').writeAsBytes(bytes);
            print('Saved frame to /sdcard/sample_frame.jpg');
          } catch (e) {
            print('Error saving frame: $e');
          }

          // Decode image
          final img.Image? capturedImage = img.decodeImage(bytes);
          if (capturedImage == null) {
            print('Failed to decode image');
            setState(() {
              _emotion = 'Error decoding image';
              _hasFace = false;
              _faceBoundingBox = null;
            });
            return;
          }
          print('Decoded image: width=${capturedImage.width}, height=${capturedImage.height}');

          // Log sample pixel values
          final samplePixel = capturedImage.getPixelSafe(100, 100);
          print('Sample pixel at (100, 100): R=${samplePixel.r}, G=${samplePixel.g}, B=${samplePixel.b}');

          // Create InputImage for face detection
          final inputImage = InputImage.fromFilePath(image.path);
          final faces = await _faceDetector!.processImage(inputImage);

          if (faces.isEmpty) {
            setState(() {
              _hasFace = false;
              _emotion = '______';
              _emotionPercentage = 0;
              _faceBoundingBox = null;
            });
            print('No faces detected');
            return;
          }

          // Select the largest face by bounding box area
          Face selectedFace = faces.reduce((a, b) {
            final areaA = a.boundingBox.width * a.boundingBox.height;
            final areaB = b.boundingBox.width * b.boundingBox.height;
            return areaA > areaB ? a : b;
          });
          if (faces.length > 1) {
            print('Multiple faces detected (${faces.length}), using largest face');
          }

          // Face detected, store bounding box
          setState(() {
            _hasFace = true;
            _faceBoundingBox = selectedFace.boundingBox;
          });

          // Crop image to face region
          final faceRect = selectedFace.boundingBox;
          final x = faceRect.left.toInt().clamp(0, capturedImage.width - 1);
          final y = faceRect.top.toInt().clamp(0, capturedImage.height - 1);
          final width = faceRect.width.toInt().clamp(1, capturedImage.width - x);
          final height = faceRect.height.toInt().clamp(1, capturedImage.height - y);
          print('Cropping face: x=$x, y=$y, width=$width, height=$height');

          final faceImage = img.copyCrop(capturedImage, x: x, y: y, width: width, height: height);
          print('Cropped image: width=${faceImage.width}, height=${faceImage.height}');

          // Resize to 224x224 for model input
          final resizedImage = img.copyResize(faceImage, width: 224, height: 224);
          final imageBytes = _preprocessImage(resizedImage);

          // Validate input tensor
          if (!_isValidInput(imageBytes)) {
            print('Invalid input tensor: Uniform or low-variance data');
            setState(() {
              _emotion = 'Invalid input';
              _emotionPercentage = 0;
            });
            return;
          }

          // Run emotion inference
          final result = await _runInference(imageBytes);
          setState(() {
            _emotion = result['emotion']!;
            _emotionPercentage = result['percentage']!;
          });
        }),
        Future.delayed(Duration(seconds: 2), () => throw TimeoutException('Frame processing timed out')),
      ]);

      // Log processing time
      print('Frame processing took: ${DateTime.now().difference(startTime).inMilliseconds}ms');
    } catch (e) {
      print('Error processing frame: $e');
      setState(() {
        _emotion = 'Error';
        _emotionPercentage = 0;
        _hasFace = false;
        _faceBoundingBox = null;
      });
    } finally {
      _isProcessingFrame = false;
    }
  }

  // Preprocesses the image for model input (224x224 RGB)
  Float32List _preprocessImage(img.Image image) {
    final input = Float32List(224 * 224 * 3);
    int pixelIndex = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixelSafe(x, y);
        // Normalize to [0, 1] for R, G, B channels
        input[pixelIndex++] = pixel.r / 255.0; // Red
        input[pixelIndex++] = pixel.g / 255.0; // Green
        input[pixelIndex++] = pixel.b / 255.0; // Blue
      }
    }
    // Log a sample of input values to check normalization
    print('Sample input values: ${input.sublist(0, 30).toList()}');
    return input;
  }

  // Runs inference on the preprocessed image
  Future<Map<String, dynamic>> _runInference(Float32List input) async {
    if (_interpreter == null) {
      print('Inference error: Model not loaded');
      return {'emotion': 'Model not loaded', 'percentage': 0};
    }
    if (_emotionLabels.isEmpty) {
      print('Inference error: Labels not loaded');
      return {'emotion': 'Labels not loaded', 'percentage': 0};
    }

    try {
      // Prepare input and output tensors
      final inputTensor = input.reshape([1, 224, 224, 3]);
      final outputTensor = List.filled(1 * _emotionLabels.length, 0.0).reshape([1, _emotionLabels.length]);

      // Validate tensor shapes
      final expectedInputShape = _interpreter!.getInputTensor(0).shape;
      final expectedOutputShape = _interpreter!.getOutputTensor(0).shape;
      print('Expected input shape: $expectedInputShape');
      print('Actual input shape: ${inputTensor.shape}');
      print('Expected output shape: $expectedOutputShape');
      print('Actual output shape: ${outputTensor.shape}');

      // Compare shapes directly
      const requiredInputShape = [1, 224, 224, 3];
      if (!expectedInputShape.asMap().entries.every((e) => e.value == requiredInputShape[e.key])) {
        print('Inference error: Input shape mismatch. Expected $requiredInputShape, got $expectedInputShape');
        return {'emotion': 'Input shape mismatch', 'percentage': 0};
      }
      if (expectedOutputShape[1] != _emotionLabels.length) {
        print('Inference error: Output shape mismatch. Expected [1, ${_emotionLabels.length}], got $expectedOutputShape');
        return {'emotion': 'Output shape mismatch', 'percentage': 0};
      }

      // Run inference
      _interpreter!.run(inputTensor, outputTensor);

      // Log the probabilities for debugging
      final probabilities = outputTensor[0].map((prob) => prob.toStringAsFixed(4)).toList();
      print('Probabilities: ${_emotionLabels.asMap().entries.map((e) => "${e.value}: ${probabilities[e.key]}").join(", ")}');

      // Find the index with the highest probability
      double maxProb = -1;
      int maxIndex = 0;
      for (int i = 0; i < _emotionLabels.length; i++) {
        if (outputTensor[0][i] > maxProb) {
          maxProb = outputTensor[0][i];
          maxIndex = i;
        }
      }

      // Convert probability to integer percentage
      final percentage = (maxProb * 100).round();

      print('Inference successful: Emotion = ${_emotionLabels[maxIndex]}, Probability = $maxProb, Percentage = $percentage%');
      return {'emotion': _emotionLabels[maxIndex], 'percentage': percentage};
    } catch (e, stackTrace) {
      print('Inference error: $e');
      print('Stack trace: $stackTrace');
      return {'emotion': 'Inference error', 'percentage': 0};
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

    // Stop frame processing and mark controller as disposed
    _frameProcessingTimer?.cancel();
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
              _frameProcessingTimer?.cancel();
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
    _frameProcessingTimer?.cancel();
    _interpreter?.close();
    _faceDetector?.close(); // Dispose of face detector
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
            // Camera preview with face bounding box overlay
            Container(
              width: double.infinity,
              height: 200, // Fixed height to maintain layout consistency
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
                    : FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController.value.previewSize?.height ?? 200,
                    height: _cameraController.value.previewSize?.width ?? 200,
                    child: Stack(
                      children: [
                        CameraPreview(_cameraController),
                        if (_hasFace && _faceBoundingBox != null)
                          CustomPaint(
                            painter: FaceOverlayPainter(
                              boundingBox: _faceBoundingBox!,
                              imageSize: Size(
                                _cameraController.value.previewSize!.height,
                                _cameraController.value.previewSize!.width,
                              ),
                              widgetSize: Size(
                                _cameraController.value.previewSize!.height,
                                _cameraController.value.previewSize!.width,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Emotion: $_emotion${_emotionPercentage > 0 ? ' ($_emotionPercentage%)' : ''}', // Display emotion with percentage
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF333333),
              ),
            ),
            // Reserve space for "No face detected" text without shifting layout
            SizedBox(
              height: 20, // Fixed height to reserve space
              child: _hasFace
                  ? const SizedBox.shrink() // Hide when face is detected
                  : Text(
                'No face detected',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.red,
                ),
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
                        borderRadius: BorderRadius.circular(8),
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

// Custom painter to draw a red square around the detected face
class FaceOverlayPainter extends CustomPainter {
  final Rect boundingBox;
  final Size imageSize;
  final Size widgetSize;

  FaceOverlayPainter({
    required this.boundingBox,
    required this.imageSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate scaling factors to map image coordinates to widget coordinates
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    // Adjust bounding box for front-facing camera (mirrored horizontally)
    final adjustedRect = Rect.fromLTRB(
      imageSize.width - boundingBox.right, // Mirror horizontally
      boundingBox.top,
      imageSize.width - boundingBox.left,
      boundingBox.bottom,
    );

    // Scale the bounding box to widget size
    final scaledRect = Rect.fromLTRB(
      adjustedRect.left * scaleX,
      adjustedRect.top * scaleY,
      adjustedRect.right * scaleX,
      adjustedRect.bottom * scaleY,
    );

    // Draw the rectangle
    canvas.drawRect(scaledRect, paint);
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return oldDelegate.boundingBox != boundingBox ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.widgetSize != widgetSize;
  }
}