import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/datasources/local/storage_service.dart';

class ExerciseSession {
  ExerciseSession({
    required this.date,
    required this.reps,
    required this.creditsEarned,
  });

  final DateTime date;
  final int reps;
  final int creditsEarned;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date.toIso8601String(),
      'reps': reps,
      'creditsEarned': creditsEarned,
    };
  }

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      date: DateTime.parse(json['date'] as String),
      reps: json['reps'] as int,
      creditsEarned: json['creditsEarned'] as int,
    );
  }
}

class ExerciseStatsProvider extends ChangeNotifier {
  ExerciseStatsProvider() : _storageService = StorageService();

  final StorageService _storageService;

  final List<ExerciseSession> sessions = <ExerciseSession>[];

  Future<void> fetchSessions() async {
    try {
      final String? raw = await _storageService.getString(
        StorageKeys.exerciseSessions,
      );
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        sessions
          ..clear()
          ..addAll(
            decoded.map(
              (dynamic e) =>
                  ExerciseSession.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
    } catch (_) {
      // Ignore corrupted storage.
    }
  }

  Future<void> _saveSessions() async {
    try {
      await _storageService.saveString(
        StorageKeys.exerciseSessions,
        jsonEncode(sessions.map((ExerciseSession s) => s.toJson()).toList()),
      );
    } catch (_) {
      // Ignore storage errors.
    }
  }

  void addSession(int reps, int creditsEarned) {
    sessions.insert(
      0,
      ExerciseSession(
        date: DateTime.now(),
        reps: reps,
        creditsEarned: creditsEarned,
      ),
    );
    _saveSessions();
    notifyListeners();
  }

  // Today's stats
  int getTodayReps() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    int totalReps = 0;
    for (final ExerciseSession session in sessions) {
      final DateTime sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      if (sessionDate == today) {
        totalReps += session.reps;
      }
    }
    return totalReps;
  }

  int getTodayPostsBlocked() {
    // Assume ~1 post blocked per rep (placeholder logic).
    return getTodayReps();
  }

  int getTodayTimeSaved() {
    // Assume ~2 minutes saved per rep (placeholder logic).
    return getTodayReps() * 2;
  }

  // Streak: consecutive days with at least 1 session
  int getStreak() {
    if (sessions.isEmpty) {
      return 0;
    }

    int streak = 0;
    DateTime? lastDate;

    for (final ExerciseSession session in sessions) {
      final DateTime sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );

      if (lastDate == null) {
        // First session
        streak = 1;
        lastDate = sessionDate;
      } else if (sessionDate == lastDate) {
        // Same day, skip
        continue;
      } else if (sessionDate
          .add(const Duration(days: 1))
          .isAtSameMomentAs(lastDate)) {
        // Consecutive day
        streak++;
        lastDate = sessionDate;
      } else {
        // Streak broken
        break;
      }
    }

    return streak;
  }
}
