import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:venture/Models/User.dart';

Future<bool> createUser(BuildContext context, String name, String email, String password) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "username": email,
    "email": name,
    "password": password,
  };

  String url = "";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    // showErrorDialog(context, "Request Timeout.", "Please try again. If this error continues to occur, please contact Kaivac.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  } 

  if (jsonResponse['result'] == "true") {
    User().name = name;
    return true;
  }
  else {
    return false;
  }
}
