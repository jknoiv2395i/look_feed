import 'dart:math' as math;

// Keypoint model with confidence levels
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

// Angle calculation utility
double calculateAngle(Keypoint p1, Keypoint p2, Keypoint p3) {
  final radians =
      math.atan2(p3.y - p2.y, p3.x - p2.x) -
      math.atan2(p1.y - p2.y, p1.x - p2.x);
  var angle = (radians * 180 / math.pi).abs();
  if (angle > 180) angle = 360 - angle;
  return angle;
}

Keypoint getKeypoint(List<Keypoint> keypoints, String name) {
  return keypoints.firstWhere(
    (kp) => kp.name == name,
    orElse: () => Keypoint(name: '', x: 0, y: 0, confidence: 0),
  );
}

// Pushup state machine
class PushupStateMachine {
  String currentState = 'neutral';
  int repCount = 0;
  double formQuality = 0.0;
  DateTime? lastRepTime;
  double minArmAngle = 180;
  double maxArmAngle = 0;

  void update(List<Keypoint> keypoints) {
    final leftArmAngle = calculateAngle(
      getKeypoint(keypoints, 'leftShoulder'),
      getKeypoint(keypoints, 'leftElbow'),
      getKeypoint(keypoints, 'leftWrist'),
    );

    final rightArmAngle = calculateAngle(
      getKeypoint(keypoints, 'rightShoulder'),
      getKeypoint(keypoints, 'rightElbow'),
      getKeypoint(keypoints, 'rightWrist'),
    );

    final avgArmAngle = (leftArmAngle + rightArmAngle) / 2;
    minArmAngle = math.min(minArmAngle, avgArmAngle);
    maxArmAngle = math.max(maxArmAngle, avgArmAngle);

    switch (currentState) {
      case 'neutral':
        if (avgArmAngle > 160) currentState = 'ready_to_descend';
        break;
      case 'ready_to_descend':
        if (avgArmAngle < 120) currentState = 'descending';
        break;
      case 'descending':
        if (avgArmAngle < 90) currentState = 'bottom_position';
        break;
      case 'bottom_position':
        if (avgArmAngle > 90) currentState = 'ascending';
        break;
      case 'ascending':
        if (avgArmAngle > 160) currentState = 'top_position';
        break;
      case 'top_position':
        if (lastRepTime == null ||
            DateTime.now().difference(lastRepTime!).inMilliseconds > 800) {
          repCount++;
          lastRepTime = DateTime.now();
          formQuality = _validateForm(keypoints, leftArmAngle, rightArmAngle);
        }
        currentState = 'ready_to_descend';
        minArmAngle = 180;
        maxArmAngle = 0;
        break;
    }
  }

  double _validateForm(
    List<Keypoint> keypoints,
    double leftAngle,
    double rightAngle,
  ) {
    double score = 0.0;
    final symmetry = (100 - (leftAngle - rightAngle).abs()) / 100;
    score += symmetry * 0.3;
    final hasFullRange = minArmAngle < 90 && maxArmAngle > 160 ? 1.0 : 0.0;
    score += hasFullRange * 0.3;
    final leftShoulder = getKeypoint(keypoints, 'leftShoulder');
    final rightShoulder = getKeypoint(keypoints, 'rightShoulder');
    final leftHip = getKeypoint(keypoints, 'leftHip');
    final rightHip = getKeypoint(keypoints, 'rightHip');
    final shoulderMid = (leftShoulder.x + rightShoulder.x) / 2;
    final hipMid = (leftHip.x + rightHip.x) / 2;
    final alignment = (100 - (shoulderMid - hipMid).abs() * 100) / 100;
    score += alignment.clamp(0, 1) * 0.4;
    return score.clamp(0, 1);
  }
}

// Squat state machine
class SquatStateMachine {
  String currentState = 'standing';
  int repCount = 0;
  double formQuality = 0.0;
  DateTime? lastRepTime;
  double minKneeAngle = 180;

  void update(List<Keypoint> keypoints) {
    final leftKneeAngle = calculateAngle(
      getKeypoint(keypoints, 'leftHip'),
      getKeypoint(keypoints, 'leftKnee'),
      getKeypoint(keypoints, 'leftAnkle'),
    );

    final rightKneeAngle = calculateAngle(
      getKeypoint(keypoints, 'rightHip'),
      getKeypoint(keypoints, 'rightKnee'),
      getKeypoint(keypoints, 'rightAnkle'),
    );

    final avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;
    minKneeAngle = math.min(minKneeAngle, avgKneeAngle);

    switch (currentState) {
      case 'standing':
        if (avgKneeAngle > 160) currentState = 'ready_to_descend';
        break;
      case 'ready_to_descend':
        if (avgKneeAngle < 140) currentState = 'descending';
        break;
      case 'descending':
        if (avgKneeAngle < 90) currentState = 'bottom_position';
        break;
      case 'bottom_position':
        if (avgKneeAngle > 90) currentState = 'ascending';
        break;
      case 'ascending':
        if (avgKneeAngle > 160) currentState = 'standing_complete';
        break;
      case 'standing_complete':
        if (lastRepTime == null ||
            DateTime.now().difference(lastRepTime!).inMilliseconds > 800) {
          repCount++;
          lastRepTime = DateTime.now();
          formQuality = _validateForm(keypoints, leftKneeAngle, rightKneeAngle);
        }
        currentState = 'ready_to_descend';
        minKneeAngle = 180;
        break;
    }
  }

  double _validateForm(
    List<Keypoint> keypoints,
    double leftAngle,
    double rightAngle,
  ) {
    double score = 0.0;
    final symmetry = (100 - (leftAngle - rightAngle).abs()) / 100;
    score += symmetry * 0.2;
    final hasDepth = minKneeAngle < 90 ? 1.0 : 0.0;
    score += hasDepth * 0.2;
    final leftKnee = getKeypoint(keypoints, 'leftKnee');
    final rightKnee = getKeypoint(keypoints, 'rightKnee');
    final leftAnkle = getKeypoint(keypoints, 'leftAnkle');
    final rightAnkle = getKeypoint(keypoints, 'rightAnkle');
    final kneeAlignment =
        (100 -
            ((leftKnee.x - leftAnkle.x).abs() +
                    (rightKnee.x - rightAnkle.x).abs()) *
                50) /
        100;
    score += kneeAlignment.clamp(0, 1) * 0.3;
    final leftShoulder = getKeypoint(keypoints, 'leftShoulder');
    final leftHip = getKeypoint(keypoints, 'leftHip');
    final backAngle = (leftShoulder.y - leftHip.y).abs();
    final backStraightness = (100 - backAngle * 10) / 100;
    score += backStraightness.clamp(0, 1) * 0.3;
    return score.clamp(0, 1);
  }
}

// Jumping Jack state machine
class JumpingJackStateMachine {
  String currentState = 'neutral';
  int repCount = 0;
  DateTime? lastRepTime;

  void update(List<Keypoint> keypoints) {
    final leftWrist = getKeypoint(keypoints, 'leftWrist');
    final rightWrist = getKeypoint(keypoints, 'rightWrist');
    final leftShoulder = getKeypoint(keypoints, 'leftShoulder');
    final rightShoulder = getKeypoint(keypoints, 'rightShoulder');
    final leftAnkle = getKeypoint(keypoints, 'leftAnkle');
    final rightAnkle = getKeypoint(keypoints, 'rightAnkle');

    final armsUp =
        leftWrist.y < leftShoulder.y - 0.1 &&
        rightWrist.y < rightShoulder.y - 0.1;
    final legSpread = (leftAnkle.x - rightAnkle.x).abs() > 0.3;

    switch (currentState) {
      case 'neutral':
        if (!armsUp && !legSpread) currentState = 'jumping_out';
        break;
      case 'jumping_out':
        if (armsUp && legSpread) currentState = 'spread_position';
        break;
      case 'spread_position':
        if (!armsUp || !legSpread) currentState = 'jumping_in';
        break;
      case 'jumping_in':
        if (!armsUp && !legSpread) {
          if (lastRepTime == null ||
              DateTime.now().difference(lastRepTime!).inMilliseconds > 800) {
            repCount++;
            lastRepTime = DateTime.now();
          }
          currentState = 'neutral';
        }
        break;
    }
  }
}
