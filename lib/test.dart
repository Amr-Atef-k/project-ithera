import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'services/storage_service.dart';
import 'services/user_prefs.dart';
import 'database_helper.dart';
import 'class/report.dart';
import 'report.dart';
import 'home.dart';
import 'dart:math' show min;

// Defines the Test widget for the mental health assessment
class Test extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Test({required this.cameras, super.key});

  @override
  _TestState createState() => _TestState();
}

// State class for Test, managing camera, questions, and user answers
class _TestState extends State<Test> {
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
    print('Face detector initialized');
  }

  // Loads the TensorFlow Lite model and emotion labels
  Future<void> _loadTFLiteModelAndLabels() async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset('assets/emotion_model.tflite');
      print('Model loaded successfully: emotion_model.tflite');

      // Log input and output tensor shapes
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      print('Input tensor: name=${inputTensor.name}, shape=${inputTensor.shape}, type=${inputTensor.type}');
      print('Output tensor: name=${outputTensor.name}, shape=${outputTensor.shape}, type=${outputTensor.type}');

      // Load labels
      final labelsData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _emotionLabels = labelsData
          .split('\n')
          .map((line) => line.trim())
          .where((label) => label.isNotEmpty)
          .map((label) => label.replaceAll(RegExp(r'^\d+\s*'), '')) // Remove leading numbers
          .toList();
      print('Loaded labels: $_emotionLabels');

      // Skip input shape validation to allow model to proceed
      // final expectedInputShape = [1, 48, 48, 1];
      // if (!inputTensor.shape.asMap().entries.every((e) => e.value == expectedInputShape[e.key])) {
      //   print('Warning: Input shape mismatch. Expected $expectedInputShape, got ${inputTensor.shape}');
      //   setState(() {
      //     _emotion = 'Input shape mismatch';
      //   });
      //   return;
      // }

      // Verify output shape
      if (outputTensor.shape.last != _emotionLabels.length) {
        print('Warning: Output shape mismatch. Expected [..., ${_emotionLabels.length}], got ${outputTensor.shape}');
        setState(() {
          _emotion = 'Output shape mismatch';
        });
        return;
      }

      print('Model and labels initialized successfully');
    } catch (e, stackTrace) {
      print('Error loading model or labels: $e');
      print('Stack trace: $stackTrace');
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
            (camera) => camera.lensDirection == CameraLensDirection.front,
      ),
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

      // Start processing frames every 1000ms for better performance
      // Adjust to 500ms if higher frame rate is needed
      _frameProcessingTimer = Timer.periodic(
        const Duration(milliseconds: 1000),
            (_) => _processCameraFrame(),
      );
    }
  }

  // Validates input tensor to detect uniform or low-variance data
  bool _isValidInput(Float32List input) {
    if (input.isEmpty) {
      print('Invalid input: Empty tensor');
      return false;
    }
    final mean = input.reduce((a, b) => a + b) / input.length;
    final variance =
        input.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / input.length;
    print('Input tensor mean: $mean, variance: $variance');
    return variance > 0.01; // Arbitrary threshold for sufficient variation
  }

  // Processes a single camera frame for face and emotion detection
  Future<void> _processCameraFrame() async {
    if (_isProcessingFrame || _isControllerDisposed || !mounted || !_isCameraInitialized) {
      print(
          'Skipping frame: Processing=$_isProcessingFrame, Disposed=$_isControllerDisposed, Mounted=$mounted, Initialized=$_isCameraInitialized');
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

          // Resize to 48x48 for model input and convert to grayscale
          final resizedImage = img.copyResize(faceImage, width: 48, height: 48);
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
        Future.delayed(
          const Duration(seconds: 2),
              () => throw TimeoutException('Frame processing timed out'),
        ),
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

  // Preprocesses the image for model input (48x48 grayscale)
  Float32List _preprocessImage(img.Image image) {
    final input = Float32List(48 * 48);
    int pixelIndex = 0;
    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        final pixel = image.getPixelSafe(x, y);
        // Convert to grayscale using luminance formula and normalize to [0, 1]
        final grayscale = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
        input[pixelIndex++] = grayscale;
      }
    }
    // Log statistics of input tensor
    final mean = input.reduce((a, b) => a + b) / input.length;
    final variance =
        input.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / input.length;
    print('Preprocessed input: mean=$mean, variance=$variance, sample=${input.sublist(0, 10).toList()}');
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
      final inputTensor = input.reshape([1, 48, 48, 1]);
      // Use dynamic output shape based on model
      final outputTensorShape = _interpreter!.getOutputTensor(0).shape;
      print('Output tensor shape: $outputTensorShape');
      final outputTensor = List.filled(outputTensorShape.reduce((a, b) => a * b), 0.0).reshape(outputTensorShape);

      // Log input tensor sample safely
      print('Input tensor sample: ${input.sublist(0, min(3, input.length))}');

      // Run inference
      final startTime = DateTime.now();
      _interpreter!.run(inputTensor, outputTensor);
      print('Inference completed in ${DateTime.now().difference(startTime).inMilliseconds}ms');

      // Log raw output tensor
      print('Raw output tensor: $outputTensor');

      // Handle output based on shape
      List<double> probabilities;
      if (outputTensorShape[0] == 1 && outputTensorShape[1] == 7) {
        probabilities = outputTensor[0].cast<double>();
      } else {
        throw Exception('Unexpected output shape: $outputTensorShape');
      }

      // Log raw output probabilities
      print(
          'Output probabilities: ${_emotionLabels.asMap().entries.map((e) => "${e.value}: ${probabilities[e.key].toStringAsFixed(4)}").join(", ")}');

      // Find the index with the highest probability
      double maxProb = -1;
      int maxIndex = 0;
      for (int i = 0; i < _emotionLabels.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // Convert probability to percentage
      final percentage = (maxProb * 100).round();
      print('Predicted emotion: ${_emotionLabels[maxIndex]}, Confidence: $maxProb ($percentage%)');

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
    print('Loaded last result: $result');
  }

  // Saves the current result to storage
  Future<void> _saveResult(String result) async {
    await _storageService.saveLastResult(result);
    setState(() {
      _lastResult = result;
    });
    print('Saved result: $result');
  }

  // Saves the test result to the database
  Future<void> _saveTestResult(int score, String resultMessage) async {
    final userId = await UserPrefs.getUserId();
    if (userId == null) {
      print('Error: User not logged in');
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
    print('Saved test result to database: score=$score, message=$resultMessage');
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
    print('Calculated score: $score');
    return score;
  }

  // Generates a result message based on the total score
  String _getResultMessage(int score) {
    if (score <= 13) {
      return 'Your mental health appears to be in a good state. You likely experience minimal distress and maintain a positive outlook. Continue nurturing your well-being with healthy habits.\n\n**Suggested Actions:** Maintain your current self-care practices, such as regular exercise, balanced nutrition, and social engagement. Consider journaling to reflect on your emotions and sustain your mental resilience.';
    } else if (score <= 27) {
      return 'You may be experiencing mild emotional challenges, such as occasional stress, sadness, or anxiety. These feelings are manageable but could benefit from attention. \n\n**Suggested Actions:** Practice relaxation techniques like deep breathing, meditation, or yoga. Engage in hobbies you enjoy and consider discussing your feelings with a trusted friend or family member to gain perspective.';
    } else if (score <= 40) {
      return 'Moderate levels of negative emotions, such as anxiety, depression, or stress, may be affecting your daily life. You might feel overwhelmed or disconnected at times. \n\n**Suggested Actions:** Seek support from a counselor or therapist proportionally to explore these feelings. Establish a routine that includes regular sleep, physical activity, and social interaction. Mindfulness practices can also help manage symptoms.';
    } else {
      return 'Significant emotional distress is indicated, which may include intense anxiety, depression, or feelings of hopelessness. These challenges could be impacting your quality of life. \n\n**Suggested Actions:** Strongly consider consulting a mental health professional for personalized support. Reach out to a support network, such as friends or family, and explore therapy options like cognitive-behavioral therapy (CBT). Prioritize self-care and avoid isolating yourself.';
    }
  }

  // Submits answers, calculates score, and navigates to the report screen
  void _submitAnswers() async {
    _totalScore = _calculateScore();
    _resultMessage = _getResultMessage(_totalScore!);
    await _saveResult('Score: $_totalScore\n$_resultMessage');
    try {
      await _saveTestResult(_totalScore!, _resultMessage!);
    } catch (e) {
      print('Error saving report: $e');
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
    print('Camera controller disposed');

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
        title: const Text('Exit Test'),
        content: const Text('Are you sure you want to exit the test?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              _frameProcessingTimer?.cancel();
              setState(() {
                _isControllerDisposed = true;
              });
              await _cameraController.dispose();
              print('Camera controller disposed on exit');
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Yes'),
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
        title: const Text('No Answer Selected'),
        content: const Text('Please select an answer to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _frameProcessingTimer?.cancel();
    _interpreter?.close();
    _faceDetector?.close();
    if (!_isControllerDisposed) {
      _cameraController.dispose();
      print('Camera controller disposed in dispose');
    }
    print('Test disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator until camera is initialized
    if (!_isCameraInitialized) {
      return const Scaffold(
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
        padding: const EdgeInsets.all(20.0), // Increased padding for better spacing
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
            const SizedBox(height: 24),
            Text(
              'Emotion: $_emotion${_emotionPercentage > 0 ? ' ($_emotionPercentage%)' : ''}',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF333333),
              ),
            ),
            // Reserve space for "No face detected" text without shifting layout
            SizedBox(
              height: 20,
              child: _hasFace
                  ? const SizedBox.shrink()
                  : Text(
                'No face detected',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Display the current question
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFA3C6C4), width: 1),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${_currentQuestionIndex + 1}. $currentQuestion',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Display answer options as radio buttons
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFA3C6C4), width: 1),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: _options.map((option) {
                    return RadioListTile<String>(
                      title: Text(
                        option,
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF333333),
                          fontSize: 15,
                        ),
                      ),
                      value: option,
                      groupValue: _selectedAnswers[_currentQuestionIndex],
                      activeColor: const Color(0xFFA3C6C4),
                      onChanged: (value) {
                        setState(() {
                          _selectedAnswers[_currentQuestionIndex] = value;
                          print('Selected answer for question ${_currentQuestionIndex + 1}: $value');
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Navigation buttons (Previous/Next/Submit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                        print('Navigated to previous question: ${_currentQuestionIndex + 1}');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ),
                const Spacer(),
                if (_currentQuestionIndex < _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedAnswers[_currentQuestionIndex] == null) {
                        _showNoAnswerAlert();
                      } else {
                        setState(() {
                          _currentQuestionIndex++;
                          print('Navigated to next question: ${_currentQuestionIndex + 1}');
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ),
                if (_currentQuestionIndex == _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedAnswers[_currentQuestionIndex] == null) {
                        _showNoAnswerAlert();
                      } else {
                        _submitAnswers();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Submit',
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