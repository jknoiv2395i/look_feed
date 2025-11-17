class PostModel {
  const PostModel({
    required this.id,
    required this.caption,
    required this.hashtags,
    required this.username,
    this.imageUrl,
    required this.isVideo,
    required this.timestamp,
  });

  final String id;
  final String caption;
  final List<String> hashtags;
  final String username;
  final String? imageUrl;
  final bool isVideo;
  final DateTime timestamp;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      caption: json['caption'] as String,
      hashtags: (json['hashtags'] as List<dynamic>).cast<String>(),
      username: json['username'] as String,
      imageUrl: json['imageUrl'] as String?,
      isVideo: json['isVideo'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'caption': caption,
      'hashtags': hashtags,
      'username': username,
      'imageUrl': imageUrl,
      'isVideo': isVideo,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
