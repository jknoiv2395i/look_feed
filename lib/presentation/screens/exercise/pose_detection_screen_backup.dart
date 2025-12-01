import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../../providers/credit_provider.dart';
import '../../../domain/entities/exercise_entity.dart';

// Keypoint model for pose detection
class Keypoint {
  final String name;
  final double x;
  final double y;
  final double confidence;
  final bool isCorrectForm;

  Keypoint({
    required this.name,
    required this.x,
    required this.y,
    required this.confidence,
    this.isCorrectForm = true,
  });
}

class PoseDetectionScreen extends StatefulWidget {
  final ExerciseType exerciseType;

  const PoseDetectionScreen({super.key, required this.exerciseType});

  @override
  State<PoseDetectionScreen> createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isSessionActive = false;
  int _repCount = 0;
  late Stopwatch _stopwatch;
  String _formFeedback = '';
  List<Keypoint> _keypoints = [];
  late Timer _timerUpdate;
  int _lastRepCheckValue = 0;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _repCount = 0;
      _lastRepCheckValue = 0;
    });
    _stopwatch.start();

    // Update UI every 100ms to show timer
    _timerUpdate = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isSessionActive && mounted) {
        setState(() {});
      }
    });

    _simulatePoseDetection();
  }

  void _stopSession() {
    _stopwatch.stop();
    _timerUpdate.cancel();
    final creditProvider = context.read<CreditProvider>();

    final creditsEarned = (_repCount ~/ 10).clamp(0, 50);
    creditProvider.addCredits(creditsEarned);

    setState(() {
      _isSessionActive = false;
    });

    _showSessionCompleteDialog();
  }

  void _simulatePoseDetection() {
    // Simulate pose detection every 100ms
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isSessionActive && mounted) {
        setState(() {
          _generateMockKeypoints();
          _updateFormFeedback();
        });
        _simulatePoseDetection();
      }
    });
  }

  void _generateMockKeypoints() {
    // Generate mock keypoints for visualization
    // In production, this would use ML Kit pose detection
    final random = DateTime.now().millisecond % 100;
    final elapsedSeconds = _stopwatch.elapsed.inSeconds;

    _keypoints = [
      // Head
      Keypoint(name: 'nose', x: 0.5, y: 0.15, confidence: 0.95),
      Keypoint(name: 'leftEye', x: 0.45, y: 0.12, confidence: 0.93),
      Keypoint(name: 'rightEye', x: 0.55, y: 0.12, confidence: 0.93),

      // Shoulders
      Keypoint(name: 'leftShoulder', x: 0.35, y: 0.3, confidence: 0.92),
      Keypoint(name: 'rightShoulder', x: 0.65, y: 0.3, confidence: 0.92),

      // Elbows
      Keypoint(
        name: 'leftElbow',
        x: 0.25 + (random / 500),
        y: 0.45,
        confidence: 0.88,
        isCorrectForm: random < 70,
      ),
      Keypoint(
        name: 'rightElbow',
        x: 0.75 - (random / 500),
        y: 0.45,
        confidence: 0.88,
        isCorrectForm: random < 70,
      ),

      // Wrists
      Keypoint(
        name: 'leftWrist',
        x: 0.15 + (random / 300),
        y: 0.6,
        confidence: 0.85,
        isCorrectForm: random < 70,
      ),
      Keypoint(
        name: 'rightWrist',
        x: 0.85 - (random / 300),
        y: 0.6,
        confidence: 0.85,
        isCorrectForm: random < 70,
      ),

      // Hips
      Keypoint(name: 'leftHip', x: 0.4, y: 0.6, confidence: 0.90),
      Keypoint(name: 'rightHip', x: 0.6, y: 0.6, confidence: 0.90),

      // Knees
      Keypoint(
        name: 'leftKnee',
        x: 0.38,
        y: 0.8,
        confidence: 0.87,
        isCorrectForm: random < 60,
      ),
      Keypoint(
        name: 'rightKnee',
        x: 0.62,
        y: 0.8,
        confidence: 0.87,
        isCorrectForm: random < 60,
      ),

      // Ankles
      Keypoint(
        name: 'leftAnkle',
        x: 0.36,
        y: 0.95,
        confidence: 0.84,
        isCorrectForm: random < 60,
      ),
      Keypoint(
        name: 'rightAnkle',
        x: 0.64,
        y: 0.95,
        confidence: 0.84,
        isCorrectForm: random < 60,
      ),
    ];

    // Detect rep completion - 1 rep per 60 seconds (1 minute)
    final expectedReps = elapsedSeconds ~/ 60;
    if (expectedReps > _lastRepCheckValue) {
      setState(() {
        _repCount = expectedReps;
        _lastRepCheckValue = expectedReps;
      });
    }
  }

  void _updateFormFeedback() {
    final incorrectKeypoints = _keypoints
        .where((kp) => !kp.isCorrectForm)
        .map((kp) => kp.name)
        .toList();

    // Check upper body form
    final upperBodyIncorrect = incorrectKeypoints
        .where(
          (kp) =>
              kp.contains('Shoulder') ||
              kp.contains('Elbow') ||
              kp.contains('Wrist') ||
              kp.contains('Eye'),
        )
        .toList();

    // Check lower body form
    final lowerBodyIncorrect = incorrectKeypoints
        .where(
          (kp) =>
              kp.contains('Hip') || kp.contains('Knee') || kp.contains('Ankle'),
        )
        .toList();

    if (incorrectKeypoints.isEmpty) {
      _formFeedback = 'Perfect form! Keep it up!';
    } else if (lowerBodyIncorrect.isNotEmpty && upperBodyIncorrect.isEmpty) {
      if (lowerBodyIncorrect.any((kp) => kp.contains('Knee'))) {
        _formFeedback = 'Keep your knees straight';
      } else if (lowerBodyIncorrect.any((kp) => kp.contains('Ankle'))) {
        _formFeedback = 'Keep your feet aligned';
      } else {
        _formFeedback = 'Adjust your leg position';
      }
    } else if (upperBodyIncorrect.isNotEmpty && lowerBodyIncorrect.isEmpty) {
      if (upperBodyIncorrect.any((kp) => kp.contains('Elbow'))) {
        _formFeedback = 'Keep your elbows aligned';
      } else if (upperBodyIncorrect.any((kp) => kp.contains('Shoulder'))) {
        _formFeedback = 'Keep your shoulders level';
      } else if (upperBodyIncorrect.any((kp) => kp.contains('Wrist'))) {
        _formFeedback = 'Keep your wrists straight';
      } else {
        _formFeedback = 'Adjust your upper body';
      }
    } else {
      _formFeedback = 'Keep your back straight';
    }
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a3a2a),
          title: const Text(
            'Session Complete!',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Reps: $_repCount',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${_stopwatch.elapsed.inMinutes}m ${_stopwatch.elapsed.inSeconds % 60}s',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Credits Earned: ${(_repCount ~/ 10).clamp(0, 50)}',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    if (_isSessionActive) {
      _timerUpdate.cancel();
    }
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a3a2a),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a3a2a),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Camera preview
            CameraPreview(_cameraController),

            // Dark overlay
            Container(color: Colors.black.withOpacity(0.3)),

            // Pose skeleton overlay
            if (_isSessionActive)
              CustomPaint(
                painter: SkeletonPainter(_keypoints),
                size: Size.infinite,
              ),

            // Top bar with exercise name and timer
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Text(
                      _getExerciseName(widget.exerciseType),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.timer, color: Color(0xFF00FF00)),
                        const SizedBox(width: 8),
                        Text(
                          '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Center rep counter
            if (_isSessionActive)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$_repCount',
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00FF00),
                        shadows: <Shadow>[
                          Shadow(color: Color(0xFF00FF00), blurRadius: 20),
                        ],
                      ),
                    ),
                    const Text(
                      'REPS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom UI
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Form feedback banner
                    if (_isSessionActive)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.2),
                          border: Border.all(
                            color: const Color(0xFFFFC107),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _formFeedback,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Control button
                    if (!_isSessionActive)
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: FloatingActionButton(
                          onPressed: _startSession,
                          backgroundColor: const Color(0xFF00FF00),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Color(0xFF1a3a2a),
                            size: 40,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: FloatingActionButton(
                          onPressed: _stopSession,
                          backgroundColor: Colors.red.withOpacity(0.8),
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getExerciseName(ExerciseType type) {
    switch (type) {
      case ExerciseType.pushups:
        return 'Push-ups';
      case ExerciseType.squats:
        return 'Squats';
      case ExerciseType.jumpingJacks:
        return 'Jumping Jacks';
      case ExerciseType.custom:
        return 'Custom Exercise';
    }
  }
}

// Custom painter for skeleton visualization
class SkeletonPainter extends CustomPainter {
  final List<Keypoint> keypoints;

  SkeletonPainter(this.keypoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final incorrectPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final circlePaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    // Draw skeleton connections
    final connections = <(String, String)>[
      ('nose', 'leftEye'),
      ('nose', 'rightEye'),
      ('leftShoulder', 'rightShoulder'),
      ('leftShoulder', 'leftElbow'),
      ('leftElbow', 'leftWrist'),
      ('rightShoulder', 'rightElbow'),
      ('rightElbow', 'rightWrist'),
      ('leftShoulder', 'leftHip'),
      ('rightShoulder', 'rightHip'),
      ('leftHip', 'rightHip'),
      ('leftHip', 'leftKnee'),
      ('leftKnee', 'leftAnkle'),
      ('rightHip', 'rightKnee'),
      ('rightKnee', 'rightAnkle'),
    ];

    // Draw lines
    for (final (start, end) in connections) {
      final startKp = keypoints.firstWhere(
        (kp) => kp.name == start,
        orElse: () => Keypoint(name: '', x: 0, y: 0, confidence: 0),
      );
      final endKp = keypoints.firstWhere(
        (kp) => kp.name == end,
        orElse: () => Keypoint(name: '', x: 0, y: 0, confidence: 0),
      );

      if (startKp.name.isNotEmpty && endKp.name.isNotEmpty) {
        final isCorrect = startKp.isCorrectForm && endKp.isCorrectForm;
        final linePaint = isCorrect ? paint : incorrectPaint;

        canvas.drawLine(
          Offset(startKp.x * size.width, startKp.y * size.height),
          Offset(endKp.x * size.width, endKp.y * size.height),
          linePaint,
        );
      }
    }

    // Draw circles for keypoints
    for (final kp in keypoints) {
      final isCorrect = kp.isCorrectForm;
      circlePaint.color = isCorrect
          ? const Color(0xFF00FF00).withOpacity(0.7)
          : const Color(0xFFFFC107).withOpacity(0.7);

      canvas.drawCircle(
        Offset(kp.x * size.width, kp.y * size.height),
        8,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(SkeletonPainter oldDelegate) => true;
}
