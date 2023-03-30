import 'package:venture/FirebaseServices.dart';

class UserModel {
  late String fid;
  int? userKey;
  String? userEmail;
  bool? isPrivate;
  bool? isVerified;
  // bool? isFollowing;
  String? userName;
  String? displayName;
  String? userBio;
  String? userAvatar;
  String? userLocation;
  List<dynamic> followers = []; // List<String>
  List<dynamic> following = []; // List<String>
  int? followingCount;
  int? followerCount;
  int? pinCount;

  UserModel.fromFirebaseMap(Map<String, dynamic> input) {
    fid = input['firebase_id'];
    userKey = int.parse(input['user_key']);
    userEmail = input['email'];
    isPrivate = input['user_is_private'] == 'Y' ? true : false;
    isVerified = input['verified'];
    // isFollowing = 
    //   FirebaseServices().firebaseId() != input['firebase_id'] ? input['followers'].contains(FirebaseServices().firebaseId()) : null;
    userName = input['username'];
    displayName = input['display_name'];
    userBio = input['biography'];
    userAvatar = input['photo_url'];
    // userLocation = input['user_location'];
    followers = input['followers'];
    following = input['following'];
    followingCount = input['following'].length;
    followerCount = input['followers'].length;
    pinCount = input['pin_count'] ?? 0;
  }

  UserModel(Map<String, dynamic> input) {
    userKey = input['user_key'];
    userEmail = input['user_email'];
    isPrivate = input['user_is_private'] == 'Y' ? true : false;
    isVerified = input['user_is_verified'] == 'Y' ? true : false;
    // isFollowing = input['following_user'] == 'Y' ? true : false;
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