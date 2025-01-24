import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String name;
  String email;
  String theme;
  String profilePicture;
  String language;

  UserModel({
    required this.name,
    required this.email,
    required this.theme,
    required this.profilePicture,
    required this.language,
  });


  //factory para crear un objeto UserModel a partir de un JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      theme: json['theme'],
      profilePicture: json['profilePicture'],
      language: json['language'],
    );
  }
}
