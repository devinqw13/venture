import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/User.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:get_storage/get_storage.dart';

Future<bool?> createUser(BuildContext context, String name, String email, String password) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "username": name,
    "email": email,
    "password": password,
  };

  String url = "${globals.apiBaseUrl}/register";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, msg: "Connection timeout. Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  } 

  if (jsonResponse['user_key'] != 0) {
    final storage = GetStorage();
    User().userKey.value = jsonResponse['user_key'];

    storage.write('user_key', User().userKey.value);
    return true;
  }
  else {
    showToast(context: context, msg: jsonResponse['message']);
    return null;
  }
}

Future<bool?> postLogin(BuildContext context, String identity, String password) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "identity": identity,
    "pwd": password,
  };

  String url = "${globals.apiBaseUrl}/postLogin";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, msg: "Connection timeout. Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  } 
  print(jsonResponse);
  if (jsonResponse['results']['status'] == true) {
    final storage = GetStorage();
    User().userKey.value = jsonResponse['results']['user_key'];

    storage.write('user_key', User().userKey.value);
    return true;
  }
  else {
    showToast(context: context, msg: "Username/email or password didn't match. Please try again.");
    return false;
  }
}

Future<UserModel?> getUser(BuildContext context, int userKey) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/getUser?user_key=$userKey";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.get(Uri.parse(url), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, msg: "Connection timeout. Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  print(jsonResponse);
  if (jsonResponse['result'] == true) {
    UserModel user = UserModel(jsonResponse['results']);
    return user;
  }
  else {
    // showToast(context: context, msg: "No user found");
    return null;
  }
}
