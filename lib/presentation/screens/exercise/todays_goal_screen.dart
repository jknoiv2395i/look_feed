import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_provider.dart';
import '../../providers/exercise_stats_provider.dart';
import '../../../domain/entities/exercise_entity.dart';
import 'pose_detection_screen.dart';

class TodaysGoalScreen extends StatefulWidget {
  const TodaysGoalScreen({super.key});

  @override
  State<TodaysGoalScreen> createState() => _TodaysGoalScreenState();
}

class _TodaysGoalScreenState extends State<TodaysGoalScreen> {
  bool _showMotivation = true;

  @override
  Widget build(BuildContext context) {
    final ExerciseProvider provider = context.watch<ExerciseProvider>();
    final ExerciseStatsProvider statsProvider = context
        .read<ExerciseStatsProvider>();

    final int todayReps = statsProvider.getTodayReps();
    final int goalReps = 30;
    final double progress = todayReps / goalReps;

    return Scaffold(
      backgroundColor: const Color(0xFF1a3a2a),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                  const Text(
                    "Today's Goal",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Progress Circle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Background circle
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 12,
                        backgroundColor: const Color(
                          0xFF00FF00,
                        ).withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00FF00),
                        ),
                      ),
                    ),
                    // Foreground circle with progress
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00FF00),
                        ),
                      ),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '$todayReps',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '/ $goalReps Mins',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Motivation Card
            if (_showMotivation)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            'Motivation for the day',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMotivation = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Dismiss',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The only bad workout is the one that didn\'t happen. Let\'s get moving!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Exercise Selection Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an Exercise',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Exercise Chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  _buildExerciseChip(
                    context,
                    'Push-ups',
                    Icons.fitness_center,
                    ExerciseType.pushups,
                    provider.currentExercise == ExerciseType.pushups,
                    () => provider.selectExercise(ExerciseType.pushups),
                  ),
                  const SizedBox(width: 12),
                  _buildExerciseChip(
                    context,
                    'Squats',
                    Icons.chair,
                    ExerciseType.squats,
                    provider.currentExercise == ExerciseType.squats,
                    () => provider.selectExercise(ExerciseType.squats),
                  ),
                  const SizedBox(width: 12),
                  _buildExerciseChip(
                    context,
                    'Jumping Jacks',
                    Icons.celebration,
                    ExerciseType.jumpingJacks,
                    provider.currentExercise == ExerciseType.jumpingJacks,
                    () => provider.selectExercise(ExerciseType.jumpingJacks),
                  ),
                  const SizedBox(width: 12),
                  _buildExerciseChip(
                    context,
                    'Plank',
                    Icons.horizontal_rule,
                    ExerciseType.custom,
                    provider.currentExercise == ExerciseType.custom,
                    () => provider.selectExercise(ExerciseType.custom),
                  ),
                  const SizedBox(width: 12),
                  _buildExerciseChip(
                    context,
                    'Crunches',
                    Icons.self_improvement,
                    ExerciseType.custom,
                    provider.currentExercise == ExerciseType.custom,
                    () => provider.selectExercise(ExerciseType.custom),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // CTA Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to pose detection screen
                        if (provider.currentExercise != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  PoseDetectionScreen(
                                    exerciseType: provider.currentExercise!,
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an exercise first'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.videocam),
                      label: const Text('Start with Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF00),
                        foregroundColor: const Color(0xFF1a3a2a),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Start manual timer
                        provider.startSession();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Manual timer started'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.timer),
                      label: const Text('Start Manual Timer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseChip(
    BuildContext context,
    String label,
    IconData icon,
    ExerciseType type,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00FF00)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: const Color(0xFF00FF00), width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1a3a2a) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1a3a2a) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
