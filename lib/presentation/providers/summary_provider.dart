import 'package:flutter/foundation.dart';

import '../../data/models/summary_model.dart';

class SummaryProvider extends ChangeNotifier {
  bool isLoading = false;
  final List<SummaryModel> summaries = <SummaryModel>[];

  Future<void> fetchSummaries() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));

    summaries
      ..clear()
      ..addAll(<SummaryModel>[
        SummaryModel(
          id: '1',
          userId: 'demo',
          postUrl: 'https://www.instagram.com/p/demo1',
          postCaption: 'How to stay focused while scrolling social media.',
          isVideo: false,
          videoTranscript: null,
          aiSummary:
              'Short breakdown of techniques to stay intentional online.',
          bulletPoints: <String>[
            'Set a clear intention before opening apps',
            'Use follow lists instead of "For You" feeds',
            'Pause to reflect after each session',
          ],
          categories: <String>['focus', 'digital-wellness'],
          isBookmarked: true,
          createdAt: DateTime.now(),
        ),
        SummaryModel(
          id: '2',
          userId: 'demo',
          postUrl: 'https://www.instagram.com/p/demo2',
          postCaption: '3 exercises to wake you up better than coffee.',
          isVideo: true,
          videoTranscript: null,
          aiSummary:
              'Quick movement routine to boost energy in under 5 minutes.',
          bulletPoints: <String>[
            'Dynamic stretches for 60 seconds',
            'Bodyweight squats or pushups',
            'Short walk and deep breathing',
          ],
          categories: <String>['exercise', 'energy'],
          isBookmarked: false,
          createdAt: DateTime.now(),
        ),
      ]);

    isLoading = false;
    notifyListeners();
  }

  void toggleBookmark(String id) {
    final int index = summaries.indexWhere((SummaryModel s) => s.id == id);
    if (index == -1) {
      return;
    }
    final SummaryModel current = summaries[index];
    summaries[index] = SummaryModel(
      id: current.id,
      userId: current.userId,
      postUrl: current.postUrl,
      postCaption: current.postCaption,
      isVideo: current.isVideo,
      videoTranscript: current.videoTranscript,
      aiSummary: current.aiSummary,
      bulletPoints: current.bulletPoints,
      categories: current.categories,
      isBookmarked: !current.isBookmarked,
      createdAt: current.createdAt,
    );
    notifyListeners();
  }
}
