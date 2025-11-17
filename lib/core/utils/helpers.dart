import 'dart:async';
import 'dart:math' as math;

class ExerciseHelpers {
  static double calculateCalories({
    required String exerciseType,
    required int reps,
    required int durationSeconds,
  }) {
    final double met;
    switch (exerciseType) {
      case 'pushups':
        met = 4.0;
        break;
      case 'squats':
        met = 5.0;
        break;
      case 'jumpingJacks':
        met = 8.0;
        break;
      default:
        met = 3.0;
        break;
    }
    final double minutes = durationSeconds / 60.0;
    return met * minutes;
  }

  static double calculateAngle(
    math.Point<double> a,
    math.Point<double> b,
    math.Point<double> c,
  ) {
    final math.Point<double> ab = math.Point<double>(a.x - b.x, a.y - b.y);
    final math.Point<double> cb = math.Point<double>(c.x - b.x, c.y - b.y);

    final double dot = ab.x * cb.x + ab.y * cb.y;
    final double magAb = math.sqrt(ab.x * ab.x + ab.y * ab.y);
    final double magCb = math.sqrt(cb.x * cb.x + cb.y * cb.y);

    if (magAb == 0 || magCb == 0) {
      return 0;
    }

    double cosTheta = dot / (magAb * magCb);
    if (cosTheta > 1) {
      cosTheta = 1;
    } else if (cosTheta < -1) {
      cosTheta = -1;
    }

    return math.acos(cosTheta) * 180 / math.pi;
  }

  static String generateUuid() {
    final math.Random random = math.Random();
    String randomHex(int length) {
      const String chars = '0123456789abcdef';
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < length; i++) {
        buffer.write(chars[random.nextInt(chars.length)]);
      }
      return buffer.toString();
    }

    return '${randomHex(8)}-${randomHex(4)}-4${randomHex(3)}-8${randomHex(3)}-${randomHex(12)}';
  }
}

class Debouncer {
  Debouncer({required this.delay});

  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
