class UserModel {
  int? userKey;
  String? userEmail;
  bool? isPrivate;
  bool? isVerified;
  bool? isFollowing;
  String? userName;
  String? displayName;
  String? userBio;
  String? userAvatar;
  String? userLocation;
  int? followingCount;
  int? followerCount;
  int? pinCount;

  UserModel(Map<String, dynamic> input) {
    userKey = input['user_key'];
    userEmail = input['user_email'];
    isPrivate = input['user_is_private'] == 'Y' ? true : false;
    isVerified = input['user_is_verified'] == 'Y' ? true : false;
    isFollowing = input['following_user'] == 'Y' ? true : false;
    userName = input['user_name'];
    displayName = input['user_display_name'];
    userBio = input['user_bio'];
    userAvatar = input['user_avatar'];
    userLocation = input['user_location'];
    followingCount = input['following_count'];
    followerCount = input['follower_count'];
    pinCount = input['pin_count'];
  }
}