import 'package:intl/intl.dart';
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
  List<String> contentUrls = [];
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
    // contentUrls = input['content_urls'] ?? [];
    contentUrls = List<String>.from(input['content_urls']);
    active = input['content_active'] == "N" ? false : true;
    contentType = input['content_type'];
    // timestamp = input['created_ts'];
    // timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toUtc());
    timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toLocal());
    contentCaption = input['content_caption'];
    user = input['user'][0] != null ? UserModel(input['user'][0]) : null;
    // contentLocation = input['content_location'];
    rating = input['avg_rating'];
    totalReviews = input['total_reviews'];
    pinLocation = input['pin_location'];
  }

  Map<String, dynamic> toJson() => 
  {
    'content_format': contentFormat,
    'content_key': contentKey,
    'relationship_key': relationshipKey,
    // int? userKey;
    'pin_key': pinKey,
    'circle_key': circleKey,
    'title': pinName,
    'content_urls': contentUrls,
    'content_url': contentUrl,
    'content_active': active,
    'content_type': contentType,
    'created_ts': timestamp,
    'content_caption': contentCaption,
    'description': pinDesc,
    // UserModel? user
    // String? contentLocation;
    'avg_rating': rating,
    'total_reviews': totalReviews,
    'pin_location': pinLocation
  };

  Content.fromMap(Map<String, dynamic> input, Map<String, dynamic> userData, ContentFormat format) {
    if(format == ContentFormat.pinContent) {
      contentFormat = format;
      contentKey = input['content_key'];
      relationshipKey = input['relationship_key'];
      pinKey = input['pin_key'];
      circleKey = input['circle_key'];
      pinName = input['title'];
      // timestamp = input['created_ts'];
      // timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toUtc());
      timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toLocal());
      pinName = input['title'];
      // contentUrls = input['content_urls'];
      contentUrls = List<String>.from(input['content_urls']);
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
      // timestamp = input['created_ts'];
      // timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toUtc());
      timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toLocal());
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
      // contentUrls = input['content_urls'];
      contentUrls = List<String>.from(input['content_urls']);
      active = input['content_active'] == "N" ? false : true;
      contentType = input['content_type'];
      // timestamp = input['created_ts'];
      // timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toUtc());
      timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(input['created_ts']).toLocal());
      contentCaption = input['description']; //input['content_caption'];
      user = input['user'] != null ? UserModel(input['user']) : null;
      // contentLocation = input['content_location'];
      rating = input['avg_rating'];
      totalReviews = input['total_reviews'];
      pinLocation = input['pin_location'];
    }
  }
}