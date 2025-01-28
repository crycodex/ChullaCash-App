
class UserModel {
  String name;
  String email;
  String theme;
  String photoUrl;
  String language;
  String userType;

  UserModel({
    required this.name,
    required this.email,
    required this.theme,
    required this.photoUrl,
    required this.language,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      theme: json['theme'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      language: json['language'] ?? '',
      userType: json['userType'] ?? '',
    );
  }
}


