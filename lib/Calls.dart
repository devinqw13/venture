import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/Content.dart';
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
    showToast(context: context, color: Colors.red, msg: "Connection timeout. Please try again.");
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
    showToast(context: context, color: Colors.red, msg: jsonResponse['message']);
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
    showToast(context: context, color: Colors.red, msg: "Connection timeout. Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  } 
  
  if (jsonResponse['results']['status'] == true) {
    final storage = GetStorage();
    User().userKey.value = jsonResponse['results']['user_key'];

    storage.write('user_key', User().userKey.value);
    return true;
  }
  else {
    showToast(context: context, color: Colors.red, msg: "Username/email or password didn't match. Please try again.");
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
    showToast(context: context, color: Colors.red, msg: "Connection timeout. Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['result'] == true) {
    UserModel user = UserModel(jsonResponse['results']);
    return user;
  }
  else {
    showToast(context: context, color: Colors.red, msg: "User not found");
    return null;
  }
}

Future<Content?> uploadContent(BuildContext context, String path, int userKey, String contentName, String contentType, {String? contentCaption, int? pinKey, int? circleKey}) async {
  Map<String, String> jsonMap = {
    "user_key": userKey.toString(),
    "content_name": contentName,
    "upload_type": contentType
  };

  if(contentCaption != null) jsonMap['content_caption'] = contentCaption;
  if(pinKey != null) jsonMap['pin_key'] = pinKey.toString();
  if(circleKey != null) jsonMap['circle_key'] = circleKey.toString();

  String url = "${globals.apiBaseUrl}/uploadContent";
  var encodedUrl = Uri.encodeFull(url);

  Map jsonResponse = {};
  http.StreamedResponse response;
  try {
    var request = http.MultipartRequest("POST", Uri.parse(encodedUrl));
    request.fields.addAll(jsonMap);
    request.files.add(await http.MultipartFile.fromPath('file', path));
    response = await request.send();
    jsonResponse = await json.decode(await response.stream.bytesToString());
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout. Please try again.");
    return null;
  }
  
  if (response.statusCode != 200) {
    showToast(context: context, color: Colors.red, msg: "An error has occured. Please try again.");
    return null;
  }
  
  if (jsonResponse['result'] == true) {
    Content content = Content(jsonResponse['results']);
    return content;
  }
  else {
    showToast(context: context, color: Colors.red, msg: jsonResponse['results']);
    return null;
  }
}

Future<bool> uploadContentV2(BuildContext context, File file, Map<String, dynamic> data) async {
  Map<String, String> converted = {};
  data['fields']['acl'] = 'public-read';
  for(var item in data['fields'].keys) {
    converted[item] = data['fields'][item].toString();
  }

  var encodedUrl = Uri.encodeFull(data['url'].toString());

  Map jsonResponse = {};
  http.StreamedResponse response;

  try {
    var request = http.MultipartRequest("POST", Uri.parse(encodedUrl));
    request.fields.addAll(converted);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    response = await request.send();
    // jsonResponse = await json.decode(await response.stream.bytesToString());
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout. Please try again.");
    return false;
  }

  if (response.statusCode == 200 || response.statusCode == 204) {
    return true;
  }else {
    showToast(context: context, color: Colors.red, msg: "An error has occured. Please try again.");
    return false;
  }
}

Future<Content?> handleContentUpload(BuildContext context, File file, int userKey, String contentName, String contentType, {String? contentCaption, int? pinKey, int? circleKey}) async {

  Map<String, String> jsonMap = {
    "user_key": userKey.toString(),
    "content_name": contentName,
    "upload_type": contentType
  };

  if(contentCaption != null) jsonMap['content_caption'] = contentCaption;
  if(pinKey != null) jsonMap['pin_key'] = pinKey.toString();
  if(circleKey != null) jsonMap['circle_key'] = circleKey.toString();

  Map<String, dynamic>? signedUrlDetails = await getS3SignedUrl(context, userKey, contentName, contentType, pinKey, circleKey);
  if(signedUrlDetails == null) return null;

  bool uploadResults = await uploadContentV2(context, file, signedUrlDetails);
  if(!uploadResults) return null;

  Content? content = await createContentDetails(context, jsonMap);
  if(content == null) return null;

  return content;
}

Future<Map<String, dynamic>?> getS3SignedUrl(BuildContext context, int userKey, String contentName, String uploadType, int? pinKey, int? circleKey) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/getS3SignedUrl?content_name=$contentName&user_key=$userKey&upload_type=$uploadType";
  
  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.get(Uri.parse(url), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout. Please try again.");
    return null;
  }

  if (response.statusCode != 200) {
    showToast(context: context, color: Colors.red, msg: "An error has occured. Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['result'] == true) {
    return jsonResponse['results'];
  }
  else {
    showToast(context: context, color: Colors.red, msg: jsonResponse['results']);
    return null;
  }
}

Future<Content?> createContentDetails(BuildContext context, Map<String, dynamic> jsonMap) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/createContentDetails";
  
  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout. Please try again.");
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
    Content content = Content(jsonResponse['results']);
    return content;
  }
  else {
    showToast(context: context, color: Colors.red, msg: jsonResponse['results']);
    return null;
  }
}

Future<List<Content>> getContent(BuildContext context, int userKey) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/getContent?user_key=$userKey";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.get(Uri.parse(url), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['result'] == 'true') {
    List<Content>? contents = [];

    for (var item in jsonResponse['results']) {
      Content content = Content(item);
      contents.add(content);
    }

    //TODO: CREATE CACHE OF RETRIEVED DATA AND SET EXPIRATION (24 hours)

    return contents;
  }
  else {
    showToast(context: context, color: Colors.red, msg: "An error has occured.");
    return [];
  }
}
