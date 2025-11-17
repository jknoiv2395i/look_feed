import '../../domain/entities/exercise_entity.dart';

class ExerciseModel {
  const ExerciseModel({
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

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      exerciseType: _exerciseTypeFromString(json['exerciseType'] as String?),
      repsCompleted: json['repsCompleted'] as int,
      durationSeconds: json['durationSeconds'] as int,
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      creditsEarned: json['creditsEarned'] as int,
      usedCameraDetection: json['usedCameraDetection'] as bool,
      formScore: json['formScore'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'exerciseType': exerciseType.name,
      'repsCompleted': repsCompleted,
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'creditsEarned': creditsEarned,
      'usedCameraDetection': usedCameraDetection,
      'formScore': formScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ExerciseType _exerciseTypeFromString(String? value) {
    switch (value) {
      case 'squats':
        return ExerciseType.squats;
      case 'jumpingJacks':
        return ExerciseType.jumpingJacks;
      case 'custom':
        return ExerciseType.custom;
      case 'pushups':
      default:
        return ExerciseType.pushups;
    }
  }
}
