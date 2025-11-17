import 'package:flutter/foundation.dart';

import '../../domain/entities/exercise_entity.dart';

class ExerciseProvider extends ChangeNotifier {
  ExerciseType? currentExercise;
  int reps = 0;
  bool isRecording = false;
  DateTime? sessionStartTime;
  bool useCameraDetection = false;

  void selectExercise(ExerciseType type) {
    currentExercise = type;
    notifyListeners();
  }

  void toggleCameraDetection(bool value) {
    useCameraDetection = value;
    notifyListeners();
  }

  void startSession() {
    isRecording = true;
    sessionStartTime = DateTime.now();
    reps = 0;
    notifyListeners();
  }

  void stopSession() {
    isRecording = false;
    notifyListeners();
  }

  void incrementRep() {
    reps++;
    notifyListeners();
  }
}
