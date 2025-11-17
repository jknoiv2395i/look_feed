class KeywordModel {
  const KeywordModel({
    required this.id,
    required this.userId,
    required this.keyword,
    required this.priority,
    this.category,
    required this.isActive,
    required this.usageCount,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String keyword;
  final int priority;
  final String? category;
  final bool isActive;
  final int usageCount;
  final DateTime createdAt;

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    return KeywordModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      keyword: json['keyword'] as String,
      priority: json['priority'] as int,
      category: json['category'] as String?,
      isActive: json['isActive'] as bool,
      usageCount: json['usageCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'keyword': keyword,
      'priority': priority,
      'category': category,
      'isActive': isActive,
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
