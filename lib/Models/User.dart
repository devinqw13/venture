import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  static final User _user = User._();
  ValueNotifier<int> userKey = ValueNotifier<int>(0);
  // int userKey = 0;
  String username = '';
  String displayName = '';
  String email = '';
  String? photoUrl;

  factory User() => _user;

  User._();

  Map<String, dynamic> toJson() => {
    'key': userKey.value,
    'name': username,
    'email': email,
    'photoUrl': photoUrl,
  };

  fromJson(Map<String, dynamic> json) {
    userKey.value = json['key'];
    username = json['name'];
    email = json['email'];
    photoUrl = json['photoUrl'];
  }

  // User.fromJson(Map<String, dynamic> json)
  // : name = json['name'],
  //   userKey = ValueNotifier<int>(json['key']),
  //   email = json['email'],
  //   photoUrl = json['photoUrl'];

  void onChange() {
    notifyListeners();
  }

  clear() {
    userKey.value = 0;
    username = "";
    displayName = "";
    email = "";
  }
}