class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
    this.subscriptionTier = SubscriptionTier.free,
  });

  final String id;
  final String email;
  final String? name;
  final String? profileImage;
  final SubscriptionTier subscriptionTier;
}

enum SubscriptionTier { free, premium }
