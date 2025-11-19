class PostEntity {
  PostEntity({
    required this.id,
    required this.username,
    required this.userAvatar,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isLiked = false,
    this.isSaved = false,
  });

  final String id;
  final String username;
  final String userAvatar;
  final String caption;
  final String imageUrl;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final bool isLiked;
  final bool isSaved;
}
