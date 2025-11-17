enum CreditSource { exercise, purchase, bonus, spent, expired }

class CreditModel {
  const CreditModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.balanceAfter,
    required this.source,
    this.exerciseId,
    this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final int amount;
  final int balanceAfter;
  final CreditSource source;
  final String? exerciseId;
  final DateTime? expiresAt;
  final DateTime createdAt;

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      balanceAfter: json['balanceAfter'] as int,
      source: _creditSourceFromString(json['source'] as String?),
      exerciseId: json['exerciseId'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'source': source.name,
      'exerciseId': exerciseId,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static CreditSource _creditSourceFromString(String? value) {
    switch (value) {
      case 'purchase':
        return CreditSource.purchase;
      case 'bonus':
        return CreditSource.bonus;
      case 'spent':
        return CreditSource.spent;
      case 'expired':
        return CreditSource.expired;
      case 'exercise':
      default:
        return CreditSource.exercise;
    }
  }
}
