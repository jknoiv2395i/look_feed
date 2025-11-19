import 'package:flutter/foundation.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider();

  int _postsViewed = 0;
  int _postsLiked = 0;
  int _postsSaved = 0;

  int get postsViewed => _postsViewed;
  int get postsLiked => _postsLiked;
  int get postsSaved => _postsSaved;

  void incrementPostsViewed() {
    _postsViewed++;
    notifyListeners();
  }

  void incrementPostsLiked() {
    _postsLiked++;
    notifyListeners();
  }

  void incrementPostsSaved() {
    _postsSaved++;
    notifyListeners();
  }

  void resetStats() {
    _postsViewed = 0;
    _postsLiked = 0;
    _postsSaved = 0;
    notifyListeners();
  }
}
