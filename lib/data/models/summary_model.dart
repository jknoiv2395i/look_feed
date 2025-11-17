class SummaryModel {
  const SummaryModel({
    required this.id,
    required this.userId,
    required this.postUrl,
    required this.postCaption,
    required this.isVideo,
    this.videoTranscript,
    required this.aiSummary,
    required this.bulletPoints,
    required this.categories,
    required this.isBookmarked,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String postUrl;
  final String postCaption;
  final bool isVideo;
  final String? videoTranscript;
  final String aiSummary;
  final List<String> bulletPoints;
  final List<String> categories;
  final bool isBookmarked;
  final DateTime createdAt;

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      postUrl: json['postUrl'] as String,
      postCaption: json['postCaption'] as String,
      isVideo: json['isVideo'] as bool,
      videoTranscript: json['videoTranscript'] as String?,
      aiSummary: json['aiSummary'] as String,
      bulletPoints: (json['bulletPoints'] as List<dynamic>).cast<String>(),
      categories: (json['categories'] as List<dynamic>).cast<String>(),
      isBookmarked: json['isBookmarked'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'postUrl': postUrl,
      'postCaption': postCaption,
      'isVideo': isVideo,
      'videoTranscript': videoTranscript,
      'aiSummary': aiSummary,
      'bulletPoints': bulletPoints,
      'categories': categories,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
