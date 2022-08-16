class Content {
  late int contentKey;
  late int relationshipKey;
  int? userKey;
  int? pinKey;
  int? circleKey;
  late String contentUrl;
  bool? active;
  String? contentType;
  String? timestamp;
  String? contentCaption;

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
  }
}