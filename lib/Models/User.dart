import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  static final User _user = User._();
  int userKey = 0;
  String name = '';
  String email = '';
  String phone = '';
  String? photoUrl;
  int languageKey = 1;

  factory User() => _user;

  User._();

  void onChange() {
    notifyListeners();
  }

  clear() {
    userKey = 0;
    name = "";
    email = "";
    phone = "";
  }
}