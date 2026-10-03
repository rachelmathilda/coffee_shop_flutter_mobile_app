class AppUser {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String pendingEmail;
  final String avatar;
  final int points;
  final String language;
  final String claimedDiscountId;
  final List<String> usedDiscounts;

  const AppUser({
    required this.uid,
    this.name = '',
    this.username = '',
    this.email = '',
    this.pendingEmail = '',
    this.avatar = '',
    this.points = 0,
    this.language = 'en',
    this.claimedDiscountId = '',
    this.usedDiscounts = const [],
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: (map['name'] ?? '') as String,
      username: (map['username'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      pendingEmail: (map['pendingEmail'] ?? '') as String,
      avatar: (map['avatar'] ?? '') as String,
      points: ((map['points'] ?? 0) as num).toInt(),
      language: (map['language'] ?? 'en') as String,
      claimedDiscountId: (map['claimedDiscountId'] ?? '') as String,
      usedDiscounts: List<String>.from((map['usedDiscounts'] ?? const []) as List),
    );
  }
}
