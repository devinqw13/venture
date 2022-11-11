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
  int? totalReviews;

  Pin(Map<String, dynamic> input) {
    pinKey = input['pin_key'];
    latLng = input['pin_location'];
    user = input['user'][0] != null ? UserModel(input['user'][0]) : null;
    title = input['title'];
    description = input['description'];
    created = DateTime.parse(input['created_ts2']);
    featuredPhoto = input['featured_photo'];
    rating = input['avg_rating'];
    totalReviews = input['total_reviews'];
  }
}