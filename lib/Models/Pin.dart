import 'dart:math';

import 'package:venture/Models/UserModel.dart';

class Pin {
  late int pinKey;
  late String latLng;
  UserModel? user;
  String? title;
  String? description;
  String? featuredPhoto;
  DateTime? created;
  double? rating;
  int? distance;
  int? totalReviews;

  Pin(Map<String, dynamic> input) {
    pinKey = input['pin_key'];
    latLng = input['pin_location'];
    user = input['user'][0] != null ? UserModel(input['user'][0]) : null;
    title = input['title'];
    description = input['description'];
    // created = DateTime.parse(input['created_ts2']);
    created =  DateTime.parse(input['created_ts2']).toLocal();
    featuredPhoto = input['featured_photo'];
    rating = input['avg_rating'];
    totalReviews = input['total_reviews'];
  }

  Pin.fromMap(Map<String, dynamic> input) {
    var selectedPinContent = input['pin_content'] != null 
                    && input['pin_content'].length > 0 ? 
                      input['pin_content'][Random().nextInt(input['pin_content'].length)] : null;
    var selectedPhoto = selectedPinContent != null ? 
                        selectedPinContent['content_urls'] != null && selectedPinContent['content_urls'].length > 0 ? selectedPinContent['content_urls'][Random().nextInt(selectedPinContent['content_urls'].length)] : null : null;

    pinKey = input['pin_key'];
    latLng = input['pin_location'];
    user =  input.containsKey('user') && input['user'] != null ? UserModel(input['user']) : null;
    title = input['title'];
    description = input['description'];
    // created = DateTime.parse(input['created_ts2']);
    created =  DateTime.parse(input['created_ts2']).toLocal();
    // featuredPhoto = input['featured_photo'];
    featuredPhoto = selectedPhoto;
    rating = input['avg_rating'];
    totalReviews = input['total_reviews'];
    distance = input['distance'] != null && input['distance'] != -1 ? input['distance'].toInt() : null;
  }
}