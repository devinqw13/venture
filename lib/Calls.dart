import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/Content.dart';
import 'package:venture/Models/VentureItem.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:get_storage/get_storage.dart';
import 'package:device_info/device_info.dart';

Future<List<String>> getDeviceDetails() async {
  String deviceName = '';
  String deviceVersion = '';
  String deviceIdentifier = '';
  String deviceType = '';
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      deviceName = build.model;
      deviceVersion = build.version.toString();
      deviceIdentifier = build.androidId;
      deviceType = 'Android';
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      deviceName = data.name;
      deviceVersion = data.systemVersion;
      deviceIdentifier = data.identifierForVendor; // UUID for iOS
      deviceType = 'iOS';
    }
  } on Exception {
    print("failed to get platform version");
  }

  return [deviceName, deviceVersion, deviceIdentifier, deviceType];
}

Future<Map<dynamic, dynamic>?> createUser(BuildContext context, String name, String email, {String? password}) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "username": name,
    "email": email
  };

  if(password != null) jsonMap['password'] = password;

  String url = "${globals.apiBaseUrl}/register";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToastV2(context: context, msg: "Connection timeout. Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  } 

  if (jsonResponse['user_key'] != 0) {
    // final storage = GetStorage();
    // VenUser().userKey.value = jsonResponse['user_key'];
    // VenUser().onChange();
    // storage.write('user_key', VenUser().userKey.value);

    return jsonResponse;
  }
  else {
    showToastV2(context: context, msg: jsonResponse['message']);
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
    showToastV2(context: context, msg: "Connection timeout. Please try again.");
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
    VenUser().userKey.value = jsonResponse['results']['user_key'];

    storage.write('user_key', VenUser().userKey.value);
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
    showToastV2(context: context, msg: "Connection timeout. Please try again.");
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
    showToastV2(context: context, msg: "User not found");
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
    showToastV2(context: context, msg: "Connection timeout. Please try again.");
    return null;
  }
  
  if (response.statusCode != 200) {
    showToastV2(context: context, msg: "An error has occurred. Please try again.");
    return null;
  }
  
  if (jsonResponse['result'] == true) {
    Content content = Content(jsonResponse['results']);
    return content;
  }
  else {
    showToastV2(context: context, msg: jsonResponse['results']);
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
    showToastV2(context: context, msg: "Connection timeout. Please try again.");
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

  Map<String, dynamic>? signedUrlDetails = await getS3SignedUrl(context, userKey, contentName, contentType, null, pinKey, circleKey);
  if(signedUrlDetails == null) return null;

  bool uploadResults = await uploadContentV2(context, file, signedUrlDetails);
  if(!uploadResults) return null;

  Content? content = await createContentDetails(context, jsonMap);
  if(content == null) return null;

  return content;
}

Future<dynamic> handleContentUploadV2(BuildContext context, List<File?> files, int userKey, String contentType, {String? contentCaption, int? pinKey, int? circleKey}) async {

  List<String> contentNames = [];

  Map<String, dynamic> jsonMap = {
    "user_key": userKey.toString(),
    "content_name": contentNames,
    "upload_type": contentType
  };

  if(contentCaption != null) jsonMap['content_caption'] = contentCaption;
  if(pinKey != null) jsonMap['pin_key'] = pinKey.toString();
  if(circleKey != null) jsonMap['circle_key'] = circleKey.toString();

  for(var item in files) {
    String? fileType = lookupMimeType(item!.path);
    late String name;
    if(fileType != null && fileType.contains('video')) {
      name = item.path.substring(item.path.lastIndexOf('/') + 1);
    } else {
      name = item.path.substring(item.path.lastIndexOf('/') + 1) + '-${VenUser().userKey.value}' + '.png';
    }

    Map<String, dynamic>? signedUrlDetails = await getS3SignedUrl(context, userKey, name, contentType, fileType, pinKey, circleKey);
    if(signedUrlDetails == null) return null;

    bool uploadResults = await uploadContentV2(context, item, signedUrlDetails);
    if(!uploadResults) return null;

    contentNames.add(name);
  }
  
  var content = await createContentDetails(context, jsonMap);
  if(content == null) return null;

  return content;
}

Future<Map<String, dynamic>?> getS3SignedUrl(BuildContext context, int userKey, String contentName, String uploadType, String? contentType, int? pinKey, int? circleKey) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/getS3SignedUrl?content_name=$contentName&user_key=$userKey&upload_type=$uploadType&content_type=$contentType";

  if(pinKey != null) url = url + '&pin_key=$pinKey';
  
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

Future<dynamic> createContentDetails(BuildContext context, Map<String, dynamic> jsonMap) async {
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

  if (jsonResponse['result'] == true) {
    Map<String, dynamic> data = jsonResponse['results'];
    if(data.containsKey('content_type')) {
      if(data['content_type'] == "post") {
        Content content = Content(jsonResponse['results']);
        return content;
      }

      if(data['content_type'] == "update-avatar") {
        return data['user_avatar'];
      }
    }
  }
  else {
    showToastV2(context: context, msg: jsonResponse['results']);
    return null;
  }
}

Future<List<Content>> getContent(BuildContext context, List<int> userKey, int dataFormat, {int? contentKey}) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/getContent?user_key=$userKey&type=$dataFormat";

  if(contentKey != null) url += '&content_key=$contentKey';

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
    List<Content> contents = [];

    for (Map<String, dynamic> item in jsonResponse['results']) {
      if(item.containsKey('pins') && item['pins'] != null) {
        for(var pin in item['pins']) {
          Content content = Content.fromMap(pin, item['user'], ContentFormat.pin);
          contents.add(content);
        }
      }
      if(item.containsKey('pin_content') && item['pin_content'] != null) {
        for(var pinContent in item['pin_content']) {
          Content content = Content.fromMap(pinContent, item['user'], ContentFormat.pinContent);
          contents.add(content);
        }
      }
      if(!item.containsKey('pin_content') && !item.containsKey('pins')) {
        Content content = Content.fromMap(item, item['user'], ContentFormat.normal);
        contents.add(content);
      }
      // Content content = Content(item);
      // contents.add(content);
    }
    contents.sort((a,b) => b.timestamp.compareTo(a.timestamp));
    //TODO: CREATE CACHE OF RETRIEVED DATA AND SET EXPIRATION (24 hours)

    return contents;
  }
  else {
    showToastV2(context: context, msg: "An error has occured.");
    return [];
  }
}

Future<List<Pin>> getMapPins(BuildContext context, {String? latlng = "", String? pinKey = "", double radius = 2}) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/getPins?pinKey=$pinKey&latlng=$latlng&radius=$radius";
  
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
    List<Pin> pins = [];

    for (var item in jsonResponse['results']) {
      Pin pin = Pin(item);
      pins.add(pin);
    }

    return pins;
  }
  else {
    showToast(context: context, color: Colors.red, msg: "An error has occured.");
    return [];
  }
}

Future<Pin?> createPin(BuildContext context, String name, String desc, String location, int userKey, {List<int>? circleKeys}) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "name": name,
    "desc": desc,
    "location": location,
    "user_key": userKey
  };

  if(circleKeys != null) jsonMap['circle_keys'] = circleKeys.toString();

  String url = "${globals.apiBaseUrl}/createPin";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['result'] == 'true') {
    Pin pin = Pin(jsonResponse['results'][0]);
    return pin;
  }
  else {
    showToast(context: context, color: Colors.red, msg: "An error has occured.");
    return null;
  }
}

Future<List<VentureItem>?> searchVenture(BuildContext context, String text, List<String>? filter) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "token": VenUser().userKey.value,
    "text": text,
    "filters": filter
  };

  String url = "${globals.apiBaseUrl}/search";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if (jsonResponse['result'] == 'true') {
    List<VentureItem> dynamicItems = [];
    for(Map<String, dynamic> item in jsonResponse['results']) {
      if(item.containsKey('users_json')) {
        if(item['users_json'] != null) {
          for(Map<String, dynamic> user in item['users_json']) {
            UserModel userItem = UserModel(user);
            VentureItem dItem = VentureItem(user: userItem);
            dynamicItems.add(dItem);
          }
        }
      }

      if(item.containsKey('pins_json')) {
        if(item['pins_json'] != null) {
          for(Map<String, dynamic> pin in item['pins_json']) {
            Pin pinItem = Pin(pin);
            VentureItem dItem = VentureItem(pin: pinItem);
            dynamicItems.add(dItem);
          }
        }
      }
    }

    // dynamicItems.sort((a, b) => a.user!.displayName!.compareTo(b.pin!.title!));

    return dynamicItems;
  }
  else {
    showToast(context: context, color: Colors.red, msg: "An error has occured.");
    return null;
  }
}

Future<List<VentureItem>?> updateProfile(BuildContext context, int key, {String? name, String? bio}) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "token": key,
  };

  if(name != null) jsonMap['name'] = name;
  if(bio != null) jsonMap['bio'] = bio;

  String url = "${globals.apiBaseUrl}/updateProfile";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['result'] == 'true') {
    return null;
  }
  else {
    showToast(context: context, color: Colors.red, msg: "An error has occured.");
    return null;
  }
}

// Used for autocomplete when searching location
Future<List<String>> getPlaces(String text, {String lang = "EN"}) async {
  final client = http.Client();
  final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&types=address&language=$lang&components=country:us&key=${globals.googleApi}';
  
  final response = await client.get(Uri.parse(request));

  if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        // return result['predictions']
        //     .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
        //     .toList();

        print(result);
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
}

Future<void> pushNotification(BuildContext context, String type, Map<String, List<String>> tokens, Map<String, dynamic> data) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "type": type,
    "tokens": tokens.values.first,
    "data": data
  };

  String url = "${globals.apiBaseUrl}/notification";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToast(context: context, color: Colors.red, msg: "Connection timeout.");
    return;
  }
  
  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  print(jsonResponse);
  // if(jsonResponse['sent_count'] > 0) {
  //   FirebaseAPI().storeNotification(context, tokens.keys.first, type, data);
  // }
}

Future<List<Pin>> getSuggestions(BuildContext context, String latLng, double radius) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  String url = "${globals.apiBaseUrl}/suggestions?latlng=$latLng&radius=$radius";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.get(Uri.parse(url), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToastV2(context: context, msg: "Connection timeout. Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['result'] == 'true') {
    List<Pin> pins = [];
    for(var item in jsonResponse['results']) {
      Pin pin = Pin.fromMap(item);
      pins.add(pin);
    }

    return pins;
  }
  else {
    showToastV2(context: context, msg: "An error has occurred.");
    return [];
  }
}

Future<void> deletePins(BuildContext context, List<int> pinKeys, String firebaseId) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "pin_keys": pinKeys,
    "firebase_id" : firebaseId
  };

  String url = "${globals.apiBaseUrl}/delete/pins";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToastV2(context: context, msg: "Connection timeout.");
    return;
  }
  
  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  print(jsonResponse);
  if(jsonResponse['pins_deleted'] == 0) {
    showToastV2(context: context, msg: "An error has occurred");
  }
}

Future<void> deleteContent(BuildContext context, List<int> contentKeys, String firebaseId) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "content_keys": contentKeys,
    "firebase_id" : firebaseId
  };

  String url = "${globals.apiBaseUrl}/delete/content";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(Uri.parse(url), body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    showToastV2(context: context, msg: "Connection timeout.");
    return;
  } catch(e) {
    showToastV2(context: context, msg: "An error has occurred.");
    return;
  }
  
  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  print(jsonResponse);
  if(jsonResponse['content_deleted'] == 0) {
    showToastV2(context: context, msg: "An error has occurred.");
  }
}