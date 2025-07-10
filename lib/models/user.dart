class User {
  User({required this.id, required this.profileImageUrl, required this.name});

  final String id;
  final String profileImageUrl;
  final String name;

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'] as String,
      profileImageUrl: json['profile_image_url'] as String,
      name: json['name'] as String,
    );
  }
}
