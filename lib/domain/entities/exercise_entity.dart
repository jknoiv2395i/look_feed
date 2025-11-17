enum ExerciseType { pushups, squats, jumpingJacks, custom }

class ExerciseEntity {
  const ExerciseEntity({
    required this.id,
    required this.userId,
    required this.exerciseType,
    required this.repsCompleted,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.creditsEarned,
    required this.usedCameraDetection,
    this.formScore,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final ExerciseType exerciseType;
  final int repsCompleted;
  final int durationSeconds;
  final double caloriesBurned;
  final int creditsEarned;
  final bool usedCameraDetection;
  final int? formScore;
  final DateTime createdAt;
}
