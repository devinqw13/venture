import 'dart:convert';
import 'package:venture/Models/UserModel.dart';

enum ContentFormat {
  pinContent,
  pin,
  normal
}

class Content {
  ContentFormat? contentFormat;
  late int contentKey;
  late int relationshipKey;
  // int? userKey;
  int? pinKey;
  int? circleKey;
  String? pinName;
  List contentUrls = [];
  String? contentUrl;
  bool? active;
  String? contentType;
  late String timestamp;
  String? contentCaption;
  String? pinDesc;
  UserModel? user;
  // String? contentLocation;
  double? rating;
  int? totalReviews;
  String? pinLocation;

  Content(Map<String, dynamic> input) {
    contentKey = input['content_key'];
    relationshipKey = input['relationship_key'];
    // userKey = input['user_key'];
    pinKey = input['pin_key'];
    circleKey = input['circle_key'];
    pinName = input['title'];
    contentUrl = input['content_url'];
    // contentUrls = input['content_urls'].map((item) => item as String)?.toList();
    contentUrls = input['content_urls'] ?? [];
    active = input['content_active'] == "N" ? false : true;
    contentType = input['content_type'];
    timestamp = input['created_ts'];
    contentCaption = input['content_caption'];
    user = input['user'][0] != null ? UserModel(input['user'][0]) : null;
    // contentLocation = input['content_location'];
    rating = input['avg_rating'];
    totalReviews = input['total_reviews'];
    pinLocation = input['pin_location'];
  }

  Content.fromMap(Map<String, dynamic> input, Map<String, dynamic> userData, ContentFormat format) {
    if(format == ContentFormat.pinContent) {
      contentFormat = format;
      contentKey = input['content_key'];
      relationshipKey = input['relationship_key'];
      pinKey = input['pin_key'];
      circleKey = input['circle_key'];
      pinName = input['title'];
      timestamp = input['created_ts'];
      pinName = input['title'];
      contentUrls = input['content_urls'];
      active = input['content_active'] == "N" ? false : true;
      contentType = input['content_type'];
      contentCaption = input['content_caption'];
      user = UserModel(userData);
      rating = input['avg_rating'];
      totalReviews = input['total_reviews'];
      pinLocation = input['pin_location'];
    }

    if(format == ContentFormat.pin) {
      contentFormat = format;
      pinName = input['title'];
      pinKey = input['pin_key'];
      pinLocation = input['location'];
      timestamp = input['created_ts'];
      pinDesc = input['description'];
    }

    if(format == ContentFormat.normal) {
      contentFormat = format;
      contentKey = input['content_key'];
      relationshipKey = input['relationship_key'];
      // userKey = input['user_key'];
      pinKey = input['pin_key'];
      circleKey = input['circle_key'];
      pinName = input['title'];
      contentUrl = input['content_url'];
      // contentUrls = input['content_urls'].map((item) => item as String)?.toList();
      contentUrls = input['content_urls'];
      active = input['content_active'] == "N" ? false : true;
      contentType = input['content_type'];
      timestamp = input['created_ts'];
      contentCaption = input['description']; //input['content_caption'];
      user = input['user'] != null ? UserModel(input['user']) : null;
      // contentLocation = input['content_location'];
      rating = input['avg_rating'];
      totalReviews = input['total_reviews'];
      pinLocation = input['pin_location'];
    }
  }
}