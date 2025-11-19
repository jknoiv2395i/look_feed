import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../../providers/credit_provider.dart';
import '../../../domain/entities/exercise_entity.dart';

class CameraExerciseScreen extends StatefulWidget {
  final ExerciseType exerciseType;

  const CameraExerciseScreen({super.key, required this.exerciseType});

  @override
  State<CameraExerciseScreen> createState() => _CameraExerciseScreenState();
}

class _CameraExerciseScreenState extends State<CameraExerciseScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isSessionActive = false;
  int _repCount = 0;
  late Stopwatch _stopwatch;

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
    });
    _stopwatch.start();

    // Simulate rep detection (in production, use ML Kit pose detection)
    _simulateRepDetection();
  }

  void _stopSession() {
    _stopwatch.stop();
    final creditProvider = context.read<CreditProvider>();

    // Award credits based on reps completed
    final creditsEarned = (_repCount ~/ 10).clamp(0, 50);
    creditProvider.addCredits(creditsEarned);

    setState(() {
      _isSessionActive = false;
    });

    // Show completion dialog
    _showSessionCompleteDialog();
  }

  void _simulateRepDetection() {
    // In production, this would use ML Kit pose detection
    // For now, we simulate rep detection every 3-5 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_isSessionActive && mounted) {
        setState(() {
          _repCount++;
        });
        _simulateRepDetection();
      }
    });
  }

  double _calculateCalories(int reps) {
    // Approximate calorie burn based on exercise type and reps
    switch (widget.exerciseType) {
      case ExerciseType.pushups:
        return reps * 0.32;
      case ExerciseType.squats:
        return reps * 0.28;
      case ExerciseType.jumpingJacks:
        return reps * 0.15;
      case ExerciseType.custom:
        return reps * 0.25;
    }
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF102217),
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
                'Calories: ${_calculateCalories(_repCount).toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Credits Earned: ${(_repCount ~/ 10).clamp(0, 50)}',
                style: const TextStyle(
                  color: Color(0xFF13ec6a),
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
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF102217),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF13ec6a)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF102217),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Camera preview
            CameraPreview(_cameraController),

            // Top overlay with exercise info
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
                      Colors.black.withOpacity(0.6),
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
                    const SizedBox(width: 28),
                  ],
                ),
              ),
            ),

            // Bottom overlay with rep counter and controls
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
                    // Rep counter
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF13ec6a),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'Reps Detected',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_repCount',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF13ec6a),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_stopwatch.elapsed.inMinutes}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Control buttons
                    if (!_isSessionActive)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _startSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF13ec6a),
                            foregroundColor: const Color(0xFF102217),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Start Session',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _stopSession,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Stop'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _repCount++;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('+ Rep'),
                            ),
                          ),
                        ],
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
