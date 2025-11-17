import 'dart:math' as math;

String formatDuration(int seconds) {
  if (seconds < 0) {
    seconds = 0;
  }
  final int hours = seconds ~/ 3600;
  final int minutes = (seconds % 3600) ~/ 60;
  final int remainingSeconds = seconds % 60;
  final String hh = hours.toString().padLeft(2, '0');
  final String mm = minutes.toString().padLeft(2, '0');
  final String ss = remainingSeconds.toString().padLeft(2, '0');
  return '$hh:$mm:$ss';
}

String formatCredits(int minutes) {
  if (minutes <= 0) {
    return '0m';
  }
  final int hours = minutes ~/ 60;
  final int remainingMinutes = minutes % 60;
  if (hours == 0) {
    return '${remainingMinutes}m';
  }
  if (remainingMinutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainingMinutes}m';
}

String formatDate(DateTime date) {
  const List<String> monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final String day = date.day.toString().padLeft(2, '0');
  final String month = monthNames[math.max(0, math.min(11, date.month - 1))];
  final String year = date.year.toString();
  return '$day $month $year';
}

String formatNumber(num value) {
  final String sign = value < 0 ? '-' : '';
  String digits = value.abs().toStringAsFixed(0);
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final int positionFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  return sign + buffer.toString();
}
