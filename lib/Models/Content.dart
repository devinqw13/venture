import 'package:venture/Models/UserModel.dart';

class Content {
  late int contentKey;
  late int relationshipKey;
  int? userKey;
  int? pinKey;
  int? circleKey;
  late String contentUrl;
  bool? active;
  String? contentType;
  late String timestamp;
  String? contentCaption;
  UserModel? user;
  String? contentLocation;
  double? rating;
  int? totalReviews;
  String? pinLocation;

  Content(Map<String, dynamic> input) {
    contentKey = input['content_key'];
    relationshipKey = input['relationship_key'];
    userKey = input['user_key'];
    pinKey = input['pin_key'];
    circleKey = input['circle_key'];
    contentUrl = input['content_url'];
    active = input['content_active'] == "N" ? false : true;
    contentType = input['content_type'];
    timestamp = input['created_ts'];
    contentCaption = input['content_caption'];
    user = input['user'][0] != null ? UserModel(input['user'][0]) : null;
    contentLocation = input['content_location'];
    rating = input['avg_rating'];
    totalReviews = input['total_reviews'];
    pinLocation = input['pin_location'];
  }
}