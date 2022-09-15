import 'package:venture/Models/UserModel.dart';

class Pin {
  late int pinKey;
  late String latLng;
  UserModel? user;
  String? title;
  String? description;
  DateTime? created;

  Pin(Map<String, dynamic> input) {
    pinKey = input['pin_key'];
    latLng = input['pin_location'];
    user = input['user'][0] != null ? UserModel(input['user'][0]) : null;
    title = input['title'];
    description = input['description'];
    created = DateTime.parse(input['created_ts2']);
  }
}