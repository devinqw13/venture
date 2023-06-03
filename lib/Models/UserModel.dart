import 'package:venture/FirebaseAPI.dart';

class UserModel {
  late String fid;
  int? userKey;
  String? userEmail;
  bool? isPrivate;
  bool? isVerified;
  bool? isFollowing;
  bool isBlocked = false;
  String? userName;
  String? displayName;
  String? userBio;
  String? userAvatar;
  String? userLocation;
  // List<dynamic> followers = []; // List<String>
  // List<dynamic> following = []; // List<String>
  int followingCount = 0;
  int followerCount = 0;
  int? pinCount;

  UserModel.fromFirebaseMap(Map<String, dynamic> input) {
    fid = input['firebase_id'];
    userKey = int.parse(input['user_key']);
    userEmail = input['email'];
    isPrivate = input['user_is_private'] == 'Y' ? true : false;
    isVerified = input['verified'];
    isFollowing = input['isFollowing'];
    isBlocked = input['isBlocked'] ?? false;
    // isFollowing = 
    //   FirebaseAPI().firebaseId() != input['firebase_id'] ? input['followers'].contains(FirebaseAPI().firebaseId()) : null;
    userName = input['username'];
    displayName = input['display_name'];
    userBio = input['biography'];
    userAvatar = input['photo_url'];
    // userLocation = input['user_location'];
    // followers = input['followers'];
    // following = input['following'];
    followingCount = input['following_count'] ?? 0;
    followerCount = input['follower_count'] ?? 0;
    pinCount = input['pin_count'] ?? 0;
  }

  Map<dynamic, dynamic> toJson() => 
  {
    'firebase_id': fid,
    'user_key': userKey.toString(),
    'email': userEmail,
    'user_is_private': isPrivate == null ? 'N' : isPrivate! ? 'Y' : 'N',
    'verified': isVerified,
    'isFollowing': isFollowing,
    'username': userName,
    'display_name': displayName,
    'biography': userBio,
    'photo_url': userAvatar,
    'following_count': followingCount,
    'follower_count': followerCount,
    'pin_count': pinCount
  };

  Map<String, Object?> toFirebaseJson() => 
  {
    'firebase_id': fid,
    'user_key': userKey.toString(),
    'email': userEmail,
    // 'user_is_private': isPrivate == null ? 'N' : isPrivate! ? 'Y' : 'N',
    'verified': isVerified,
    // 'isFollowing': isFollowing,
    'username': userName,
    'display_name': displayName,
    'biography': userBio,
    'photo_url': userAvatar,
    // 'following_count': followingCount,
    // 'follower_count': followerCount,
    // 'pin_count': pinCount
  };

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
    followingCount = input['following_count'] ?? 0;
    followerCount = input['follower_count'] ?? 0;
    pinCount = input['pin_count'];
  }
}