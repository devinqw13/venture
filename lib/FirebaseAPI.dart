import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/Notification.dart';
import 'package:venture/Models/VenUser.dart';

class FirebaseAPI extends ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
 
  Stream<dynamic> getContent() {
    return _firestore.collection('pins')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<dynamic> getReactions(String contentKey) {
    return _firestore.collection('content')
        .where('content_key', isEqualTo: contentKey)
        .snapshots()
        .map((snapshot) => snapshot.docs
          .map((document) {
            Map<String, dynamic> data = document.data();
            data.update('documentId', (value) => value, ifAbsent: () => document.id);
            return data;
          }).toList().first);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>?> getReactionsV2(String contentKey, String? documentId) {
    return _firestore.collection('content')
        .doc(documentId)
        .collection("reactions")
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>?> getReactionsV3(String contentKey) {
    return _firestore.collection('content_reactions')
      .where('content_key', isEqualTo: contentKey)
      .snapshots();
  }

  Future<dynamic> getContentFromKey(String contentKey) async {
    return await _firestore.collection('content')
      .where('content_key', isEqualTo: contentKey).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getComments(String? documentId) async {
    return await _firestore.collection('content')
      .doc(documentId)
      .collection('comments')
      .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getCommentsV2(String contentKey) async {
    return await _firestore.collection('content_comments')
      .where('content_key', isEqualTo: contentKey)
      .get();
  }

  Stream<dynamic> getContentDoc(String contentKey) {
    return _firestore.collection('content')
      .where('content_key', isEqualTo: contentKey)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((document) {
            Map<String, dynamic> data = document.data();
            data.update('documentId', (value) => value, ifAbsent: () => document.id);
            return data;
          }).toList().first);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkUsername(String username) async {
    return _firestore.collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  Future<int> getUserFollowingCount(String firebaseId) async {
    try {
      AggregateQuerySnapshot query = await _firestore.collection('users').doc(firebaseId).collection('following').count().get();

      return query.count;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<int> getUserFollowerCount(String firebaseId) async {
    try {
      AggregateQuerySnapshot query = await _firestore.collection('users').doc(firebaseId).collection('followers').count().get();

      return query.count;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Stream<Iterable<Stream<Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>>>> unreadMessagesStream(String userKey) {
    var res = _firestore.collection('conversations').where('owners', arrayContains: userKey).snapshots().map((snapshot) => snapshot.docs.map((e) => _firestore.collection('conversations').doc(e.id).collection('messages').snapshots().map((snapshot2) => snapshot2.docs.where((doc) => doc['read'] == false && doc['user_key'] != userKey).toList()).map((event) => {e.id: event})));

    return res;
  }

  Stream<List<dynamic>> unreadNotificationsStream(String firebaseId) {
    var result = _firestore.collection('notifications').doc(firebaseId).snapshots().map((event) => event.data() ?? {}).map((event) => event.values.map((e) => e.where((e) => e['read'] == false).toList()).toList()).map((event) {
      List list = [];
      for(var i in event) {
        for(var k in i) {
          list.add(k);
        }
      }
      return list;
    });

    return result;
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getUserDetails({String? username, String? userKey}) async {
    if(username != null) {
      return await _firestore.collection('users')
        .where('username', isEqualTo: username)
        .get();
    }

    if(userKey != null) {
      return await _firestore.collection('users')
        .where('user_key', isEqualTo: userKey)
        .get();
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUserDetailsV2({String? username, String? userKey}) async {
    if(username != null) {
      return await _firestore.collection('users')
        .where('username', isEqualTo: username)
        .get().then((v) {
          return v.docs.first.data();
        });
    }

    if(userKey != null) {
      return await _firestore.collection('users')
        .where('user_key', isEqualTo: userKey)
        .get().then((v) async {
          Map<String, dynamic> data = v.docs.first.data();

          if(FirebaseAuth.instance.currentUser != null && v.docs.first.id != FirebaseAuth.instance.currentUser!.uid) {
            bool isFollowing = await checkIfFollowing(v.docs.first.id);

            data.update('isFollowing', (value) => value, ifAbsent: () => isFollowing);
          }
          int followingCount = await getUserFollowingCount(v.docs.first.id);
          data.update('following_count', (value) => value, ifAbsent: () => followingCount);
          int followerCount = await getUserFollowerCount(v.docs.first.id);
          data.update('follower_count', (value) => value, ifAbsent: () => followerCount);
          return data;
        });
    }

    return null;
  }

  Future<UserCredential?> createUserWithEmailAndPassword(BuildContext context, String username, String email, String password) async {
    UserCredential? userCredential;

    var user = await checkUsername(username);
    if(user.docs.isNotEmpty) {
      showToastV2(context: context, msg: "The username already exists.");
      return null;
    }

    try {
      Map<dynamic, dynamic>? result = await createUser(context, username, email);

      if(result == null) return null;

      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      if (userCredential.user != null) {

        var userRef = _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
        userRef.set({
          'user_key': result['user_key'].toString(),
          'username': username,
          'display_name': null,
          'email': userCredential.user!.email!,
          'firebase_id': FirebaseAuth.instance.currentUser!.uid,
          'photo_url': 'https://venture-content.s3.amazonaws.com/images/default-avatar.jpg',
          'biography': null,
          'verified': false,
          'user_deactivated': false,
          'user_terminated': false
        }, SetOptions(merge: true)).then((value) {
        }).catchError((error) {print("Failed to add message: $error");});

        final storage = GetStorage();
        VenUser().userKey.value = result['user_key'];
        VenUser().email = userCredential.user!.email!;
        VenUser().onChange();
        storage.write('user_key', VenUser().userKey.value);
        storage.write('user_email', userCredential.user!.email);

        // setFirebaseToken();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToastV2(context: context, msg: "The email is already in use.");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }

    return userCredential;
  }

  Future<UserCredential?> login(BuildContext context, String user, String password) async {
    UserCredential? userCredential;
    
    if(!user.contains("@")) {
      var result = await getUserDetails(username: user.toLowerCase());
      if(result == null || result.docs.isEmpty) {
        showToastV2(context: context, msg: "User was not found", forcedBrightness: Brightness.light);
        return null;
      }
      user = result.docs.first.data()['email'];
    }

    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user,
        password: password
      );

      if (userCredential.user != null) {
        final storage = GetStorage();

        var userDetails = await _firestore.collection('users')
        .where('email', isEqualTo: user)
        .get();

        int userKey = int.parse(userDetails.docs.first.data()['user_key']);
        bool deactivated = userDetails.docs.first.data()['user_deactivated'];
        
        if(deactivated) {
          var result = await reactivateVentureAccount(context, userKey, userCredential.user!.uid, isSelf: true);

          if(result) {
            VenUser().userKey.value = userKey;
            VenUser().email = userCredential.user!.email!;
            VenUser().onChange();
            storage.write('user_key', VenUser().userKey.value);
            storage.write('user_email', user);
          }else {
            userCredential = null;
          }
        }else {
          VenUser().userKey.value = userKey;
          VenUser().email = userCredential.user!.email!;
          VenUser().onChange();
          storage.write('user_key', VenUser().userKey.value);
          storage.write('user_email', user);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToastV2(context: context, msg: "User was not found", forcedBrightness: Brightness.dark);
        return null;
      } else if (e.code == 'wrong-password') {
        showToast(context: context, msg: "Username/email or password did not match");
        return null;
      } else if (e.code == 'user-disabled') {
        showCustomDialog(
          context: context,
          title: 'Account restricted', 
          description: "Your account has been restricted from any activity. We restricted your account to prevent any action and to protect others. Contact customer service for assistance.",
          descAlignment: TextAlign.center,
          buttons: {
            "OK": {
              "action": () => Navigator.of(context).pop(),
              "textColor": Get.isDarkMode ? Colors.white : Colors.black,
              "alignment": TextAlign.center
            },
          }
        );
        return null;
      }
    }catch (e) {
      print(e);
      return null;
    }

    return userCredential;
  }

  Future<bool> reauthenticate(BuildContext context, String email, String password) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      var credential = EmailAuthProvider.credential(
        email: email,
        password: password
      );
      UserCredential? userData = await user?.reauthenticateWithCredential(credential);

      if(userData != null) return true;

      return false;
    } on FirebaseAuthException catch(e) {
      if(e.code == 'wrong-password') {
        showCustomDialog(
          context: context,
          title: 'Wrong password', 
          description: "The password you have entered was incorrect. Please try again.",
          descAlignment: TextAlign.center,
          buttonDirection: Axis.vertical,
          buttons: {
            "OK": {
              "action": () => Navigator.of(context).pop(),
              "textColor": Get.isDarkMode ? Colors.white : Colors.black,
              "alignment": TextAlign.center
            },
          }
        );
      }
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  String? firebaseId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<bool> updateUserData(BuildContext context, String firebaseId, {String? username, String? displayName, String? email, String? bio, String? avatar}) async {
    Map<String, dynamic> updatedData = {};

    if(displayName != null) updatedData['display_name'] = displayName;
    if(bio != null) updatedData['biography'] = bio;
    if(avatar != null) updatedData['photo_url'] = avatar;

    if(username != null) {
      var result = await checkUsername(username);
      if(result.docs.isNotEmpty) {
        showToast(context: context, msg: "The username already exists.");
      }else {
        updatedData['username'] = username;
      }
    }

    bool result = true;
    var userRef = _firestore.collection('users').doc(firebaseId);
    userRef.update(updatedData).catchError((error) {print("Failed to update user: $error");}).onError((error, stackTrace) => result = false);

    return result;
  }

  Future<void> updatePassword(BuildContext context, String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      showToastV2(context: context, msg: "Unable to update password");
      return;
    }
    await user.updatePassword(password);
    showToastV2(context: context, msg: "Password was updated successfully!");
  }

  Future<void> addReaction(String? documentId, int contentKey) async {
    HapticFeedback.mediumImpact();

    if(documentId != null) {
      var rxRef = _firestore.collection('content').doc(documentId);
      rxRef.update({
      "reactions": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    }).catchError((error) {print("Failed to add message: $error");});
    }else {
      var rxRef = _firestore.collection('content').doc();
      rxRef.set({
        'content_key': contentKey.toString(),
        'reactions': [FirebaseAuth.instance.currentUser!.uid]
      }, SetOptions(merge: true)).then((value) {
      }).catchError((error) {print("Failed to add message: $error");});
    }
  }

  Future<void> addReactionV2(BuildContext context, String? documentId, int contentKey, {Map<String, dynamic>? data}) async {
    HapticFeedback.mediumImpact();

    if(documentId != null) {
      _firestore.collection('content').doc(documentId).collection('reactions').doc(FirebaseAuth.instance.currentUser!.uid).set({'timestamp': DateTime.now().toUtc()})
      .then((v) async {
        // SEND NOTIFICATION
        reactionNotification(context, data);
      });
    }else {
      await addReactionFromKey(context, contentKey, data: data);
    }
  }

  Future<void> addReactionV3(BuildContext context, String contentKey, String pinKey, {Map<String, dynamic>? data}) async {
    HapticFeedback.mediumImpact();

    String documentId = FirebaseAPI().firebaseId()! + "-" + contentKey;
    
    _firestore.collection('content_reactions').doc(documentId).set({
      'firebase_id': FirebaseAPI().firebaseId(),
      'content_key': contentKey,
      'pin_key': pinKey,
      'timestamp': DateTime.now().toUtc()
    }).then((v) async {
      // SEND NOTIFICATION
      reactionNotification(context, data);
    });
  }

  Future<void> addReactionFromKey(BuildContext context, int contentKey, {Map<String, dynamic>? data}) async {
    var content = await _firestore.collection('content').where('content_key', isEqualTo: contentKey.toString()).get();

    if(content.docs.isNotEmpty) {
      var documentId = content.docs.first.id;
      _firestore.collection('content').doc(documentId).collection('reactions').doc(FirebaseAuth.instance.currentUser!.uid).set({'timestamp': DateTime.now().toUtc()})
      .then((v) {
        // SEND NOTIFICATION
        reactionNotification(context, data);
      });
    } else {
      var rxRef = _firestore.collection('content').doc();
      rxRef.set({
        'content_key': contentKey.toString(),
        'pin_key': data!['pin_key'].toString()
        // 'reactions': [FirebaseAuth.instance.currentUser!.uid]
      }, SetOptions(merge: true)).then((value) {
      }).then((value) {
        rxRef.collection("reactions").doc(FirebaseAuth.instance.currentUser!.uid).set({'timestamp': DateTime.now().toUtc()})
        .then((v) {
          // SEND NOTIFICATION
          reactionNotification(context, data);
        });
      });
    }
  }

  Future<void> reactionNotification(BuildContext context, Map<String, dynamic>? data) async {
    Map<String, dynamic> notiData = {};
    var results = await getUserFromFirebaseId(FirebaseAuth.instance.currentUser!.uid);
    notiData['reaction_by'] = json.encode(results);

    if(data != null) notiData['content_data'] = json.encode(data);

    if(results['user_key'] != data!['user_key'].toString()) {
      sendNotification(
        context,
        "reactions",
        notiData,
        userKey: data['user_key'].toString()
      );
    }
  }

  Future<void> removeReaction(String documentId) async {
    // HapticFeedback.lightImpact();
    var rxRef = _firestore.collection('content').doc(documentId);
    rxRef.update({
      "reactions": FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    }).catchError((error) {print("Failed to remove reaction: $error");});
  }

  Future<void> removeReactionV2(String documentId) async {
    // HapticFeedback.lightImpact();
    var _ = _firestore.collection('content').doc(documentId).collection('reactions').doc(FirebaseAuth.instance.currentUser!.uid).delete().onError((error, stackTrace) => print("Failed to remove reaction: $error"));
  }

  Future<void> removeReactionV3(String contentKey) async {
    // HapticFeedback.lightImpact();
    String documentId = FirebaseAPI().firebaseId()! + "-" + contentKey;

    var _ = _firestore.collection('content_reactions').doc(documentId).delete().onError((error, stackTrace) => print("Failed to remove reaction: $error"));
  }

  Query<Object?> likedByQuery(String? documentId) {
    return FirebaseFirestore.instance.collection('content').doc(documentId).collection('reactions').orderBy('timestamp', descending: true);
  }

  Query<Object?> likedByQueryV2(String contentKey) {
    return _firestore.collection('content_reactions').where('content_key', isEqualTo: contentKey).orderBy('timestamp', descending: true);
  }

  Query<Object?> commentQuery(String? documentId) {
    return _firestore.collection('content').doc(documentId).collection('comments').orderBy('timestamp', descending: true);
  }

  Query<Object?> commentQueryV2(String contentKey) {
    var res = _firestore.collection('content_comments').where(Filter('content_key', isEqualTo: contentKey));

    return res;
  }

  Query<Object?> followersQuery(String? documentId) {
    return _firestore.collection('users').doc(documentId).collection('followers');
  }

  Query<Object?> followingQuery(String? documentId) {
    return _firestore.collection('users').doc(documentId).collection('following');
  }

  Future<Map<String, dynamic>> getUserFromFirebaseId(String id) async {
    return await _firestore.collection('users')
      .doc(id)
      .get().then((v) async {
        Map<String, dynamic>? data = v.data();
        if(id != FirebaseAuth.instance.currentUser!.uid) {
          bool isFollowing = await checkIfFollowing(id);

          data!.update('isFollowing', (value) => value, ifAbsent: () => isFollowing);
        }

        return data!;
      });
  }

  Future<void> updateFollowStatus(String firebaseId, bool shouldFollow) async {
    HapticFeedback.mediumImpact();
    if(shouldFollow) {

      var userRef = _firestore.collection('users').doc(firebaseId);

      userRef.update({
        "followers": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      }).catchError((error) {print("Failed to add message: $error");}).then((value) {

        var userRef = _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

        userRef.update({
          "following": FieldValue.arrayUnion([firebaseId])
        }).catchError((error) {print("Failed to add message: $error");});

      });
    } else {
      var userRef = _firestore.collection('users').doc(firebaseId);

      userRef.update({
        "followers": FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      }).catchError((error) {print("Failed to remove reaction: $error");}).then((value) {

        var userRef = _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

        userRef.update({
          "following": FieldValue.arrayRemove([firebaseId])
        }).catchError((error) {print("Failed to add message: $error");});

      });
    }
  }

  Future<bool> checkIfFollowing(String firebaseId) async {
    try {
      // Get reference to Firestore collection
      var doc = await _firestore.collection('users').doc(firebaseId).collection('followers').doc(FirebaseAuth.instance.currentUser!.uid).get();

      return doc.exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updateFollowStatusV2(String firebaseId, bool shouldFollow) async {
    HapticFeedback.mediumImpact();

    var followersCollection = _firestore.collection('users').doc(firebaseId).collection('followers');
    var followingCollection = _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('following');

    if(shouldFollow) {

      followersCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
        'timestamp': DateTime.now().toUtc(),
      }).then((v) {
        followingCollection.doc(firebaseId).set({
          'timestamp': DateTime.now().toUtc(),
        });
      });

    }else {
      followersCollection.doc(FirebaseAuth.instance.currentUser!.uid).delete().then((v) {
        followingCollection.doc(firebaseId).delete();
      });
    }
  }

  Future<void> deleteComment(String contentId, String commentId) async {
    await _firestore.collection('content').doc(contentId).collection('comments').doc(commentId).delete();
  }

  Future<void> deleteCommentV2(String commentId) async {
    await _firestore.collection('content_comments').doc(commentId).delete();
  }

  Future<String> addComment(BuildContext context, String? documentId, int contentKey, String comment, {Map<String, dynamic>? data}) async {
    // HapticFeedback.mediumImpact();

    if(documentId != null) {
      _firestore.collection('content').doc(documentId).collection('comments').doc().set({
        'timestamp': DateTime.now().toUtc(),
        'comment': comment,
        'firebase_id': FirebaseAuth.instance.currentUser!.uid
      }).then((v) {
        // SEND NOTIFICATION
        commentNotification(context, data);
      });
    }else {
      var rxRef = _firestore.collection('content').doc();
      documentId = rxRef.id;
      rxRef.set({
        'content_key': contentKey.toString(),
        'pin_key': data!['pin_key'].toString()
      }, SetOptions(merge: true)).then((value) {
      }).then((value) {
        rxRef.collection("comments").doc().set({
          'timestamp': DateTime.now().toUtc(),
          'comment': comment,
          'firebase_id': FirebaseAuth.instance.currentUser!.uid
        }).then((v) {
          // SEND NOTIFICATION
          data['documentId'] = documentId;
          commentNotification(context, data);
        });
      });
    }

    return documentId;
  }

  Future<void> addCommentV2(BuildContext context, String contentKey, String pinKey, String comment, {Map<String, dynamic>? data}) async {
    // HapticFeedback.mediumImpact();

    _firestore.collection('content_comments').doc().set({
      'firebase_id': FirebaseAuth.instance.currentUser!.uid,
      'content_key': contentKey,
      'pin_key': pinKey,
      'comment': comment,
      'timestamp': DateTime.now().toUtc(),
    }).then((v) {
      // SEND NOTIFICATION
      // commentNotification(context, data);
    });
  }

  Future<void> commentNotification(BuildContext context, Map<String, dynamic>? data) async {
    Map<String, dynamic> notiData = {};
    var results = await getUserFromFirebaseId(FirebaseAuth.instance.currentUser!.uid);
    notiData['comment_by'] = json.encode(results);

    if(data != null) notiData['comment_data'] = json.encode(data);

    if(results['user_key'] != data!['user_key'].toString()) {
      sendNotification(
        context,
        "content_comment",
        notiData,
        userKey: data['user_key'].toString()
      );
    }
  }

  Future<void> firebaseCloudMessagingListeners() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('User granted permission: ${settings.authorizationStatus}');
    }

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    setFirebaseToken();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('type')) {
        if (message.data['type'] == 'message') {
          if (message.data.containsKey('owners')) {
            List<String> _ = message.data['owners'].toString().replaceAll(' ', '').split(',');
            // MessagingScreen messagingScreen = new MessagingScreen(goToConversation: true, owners: owners);
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => messagingScreen));
          }
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      // RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      // if (notification != null && android != null) {
      //   flutterLocalNotificationsPlugin.show(
      //     notification.hashCode,
      //     notification.title,
      //     notification.body,
      //     NotificationDetails(
      //       android: AndroidNotificationDetails(
      //         channel.id,
      //         channel.name,
      //         channelDescription: channel.description,
      //         icon: android.smallIcon,
      //         priority: Priority.max
      //         // other properties...
      //       ),
      //     )
      //   );
      // }
    });
  }

  Future<void> setFirebaseToken() async {
    if(FirebaseAuth.instance.currentUser != null){
      _firebaseMessaging.getToken().then((token) async {
        var userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

        final storage = FlutterSecureStorage();
        String? deviceUniqueID = await storage.read(key: 'AppUID');

        userRef.set({
          'firebase_tokens': {
            deviceUniqueID: token
          }
        }, SetOptions(merge: true)).then((value) {
        }).catchError((error) {print("Failed to add message: $error");});
      });
    }
  }

  Future<void> removeFirebaseTokens() async {
    // Find matching firebase token for current user and remove it from Firestore
    // so you don't receive push notifications on a specific device after logging out
    var userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

    final storage = FlutterSecureStorage();
    String? deviceUniqueID = await storage.read(key: 'AppUID');
    print(deviceUniqueID);

    var doc = await userRef.get();

    Map<String, String> tokens = Map<String, String>.from(doc.get('firebase_tokens'));

    tokens.removeWhere((key, value) => key == deviceUniqueID);

    await userRef.update({
      'firebase_tokens': tokens
    }).then((value) {}).catchError((error) {print("Failed to remove firebase token: $error");});
  }

  Future<Map<String, List<String>>> getFirebaseTokens({String? firebaseId, String? userKey}) async {
    if(firebaseId != null) {
      var result = await _firestore.collection('users').doc(firebaseId).get();

      Map<String, dynamic>? tokens = result.data()?['firebase_tokens'];
      List<String>? fbTokens = (tokens?.values.toList())?.map((e) => e as String).toList();
      return {firebaseId: fbTokens ?? []};
    }else if(userKey != null) {
      var result = await _firestore.collection('users').where('user_key', isEqualTo: userKey).get();

      if(result.docs.isNotEmpty) {
        var data = result.docs.first.data();
        String firebaseId = data['firebase_id'];
        Map<String, dynamic>? tokens = data['firebase_tokens'];
        List<String>? fbTokens = (tokens?.values.toList())?.map((e) => e as String).toList();
        return {firebaseId: fbTokens ?? []};
      }
    }

    return {};
  }

  Future<void> messageNotification(BuildContext context, Map<String, dynamic>? data) async {
    Map<String, dynamic> notiData = {};
    var results = await getUserFromFirebaseId(FirebaseAuth.instance.currentUser!.uid);
    notiData['message_by'] = json.encode(results);

    if(data != null) notiData['message_data'] = json.encode(data);

    if(results['user_key'] != data!['user_key'].toString()) {
      sendNotification(
        context,
        "convo_message",
        notiData,
        userKey: data['user_key'].toString()
      );
    }
  }

  Future<void> sendNotification(BuildContext context, String type, Map<String, dynamic> data, {String? firebaseId, String? userKey}) async {

    Map<String, List<String>> tokens = {};
    if(firebaseId != null) {
      tokens = await FirebaseAPI().getFirebaseTokens(firebaseId: firebaseId);
    }else if(userKey != null) {
      tokens = await FirebaseAPI().getFirebaseTokens(userKey: userKey);
    }

    bool result = await storeNotification(context, tokens.keys.first, type, data);

    if(result && tokens.isNotEmpty && tokens.values.isNotEmpty && tokens.values.first.isNotEmpty) {
      pushNotification(
        context,
        type,
        tokens,
        data
      );
    }
  }

  Future<bool> storeNotification(BuildContext context, String firebaseId, String type, Map<String, dynamic> data) async {
    // bool success = false; 
    Map<String, dynamic> jsonMap = {};
    jsonMap['timestamp'] = DateTime.now().toUtc();
    jsonMap['read'] = false;

    if(type == 'content_comment') {
      type = 'content_comments';
      jsonMap['firebase_id'] = json.decode(data['comment_by'])['firebase_id'];
      jsonMap['comment'] = json.decode(data['comment_data'])['comment'];
      jsonMap['content_photo'] = json.decode(data['comment_data'])['content_image_url'];
      jsonMap['content_key'] = json.decode(data['comment_data'])['content_key'];
      jsonMap['pin_key'] = json.decode(data['comment_data'])['pin_key'];
    }
    else if(type == 'reactions') {
      jsonMap['firebase_id'] = json.decode(data['reaction_by'])['firebase_id'];
      jsonMap['content_photo'] = json.decode(data['content_data'])['content_image_url'];
      jsonMap['content_key'] = json.decode(data['content_data'])['content_key'];
      jsonMap['pin_key'] = json.decode(data['content_data'])['pin_key'];
    }
    else if(type == 'rate_pin') {
      jsonMap['firebase_id'] = json.decode(data['rating_by'])['firebase_id'];
      jsonMap['content_photo'] = json.decode(data['rating_data'])['content_image_url'];
      jsonMap['pin_key'] = json.decode(data['rating_data'])['pin_key'];
      jsonMap['rating'] = json.decode(data['rating_data'])['rating'];
    }
    else if(type == 'convo_message') {
      // type = 'messages';
      // jsonMap['firebase_id'] = json.decode(data['message_by'])['firebase_id'];
      return true;
    }

    var notiRef = _firestore.collection('notifications').doc(firebaseId);
    var result = await notiRef.set({
      type: FieldValue.arrayUnion([jsonMap])
    }, SetOptions(merge: true)).then((_) {
      return true;
    })
    .catchError((error) {
      print("Failed to add notification: $error");
      return false;
    });
    
    return result;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getNotifications() async {
    return await FirebaseFirestore.instance.collection('notifications').doc(FirebaseAuth.instance.currentUser!.uid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getNotificationsStream() {
    return FirebaseFirestore.instance.collection('notifications').doc(FirebaseAuth.instance.currentUser!.uid).snapshots();
  }

  Future<void> updateNotificationsRead(List<Map<String, dynamic>> data, NotificationType notificationType) async {
    var notiRef = FirebaseFirestore.instance.collection('notifications').doc(FirebaseAuth.instance.currentUser!.uid);

    String key = '';
    if(notificationType == NotificationType.comment) {
      key = 'content_comments';
    }else if(notificationType == NotificationType.reaction) {
      key = 'reactions';
    }else if(notificationType == NotificationType.followed) {
      key = 'followed_you';
    }else if(notificationType == NotificationType.message) {
      key = 'messages';
    }else if(notificationType == NotificationType.ratePin) {
      key = 'rate_pin';
    }

    if(key.isNotEmpty) {
      await notiRef.update({
        key: data
      }).then((value) {}).catchError((error) {print("Failed to remove firebase token: $error");});
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getSavedPins(String firebaseId) async {
    return await _firestore.collection('users')
      .doc(firebaseId)
      .collection('saved_pins')
      .get();
  }

  Future<bool> checkSavedPin(String firebaseId, String pinKey) async {
    var result = await _firestore.collection('users').doc(firebaseId).collection('saved_pins').where('pin_key', isEqualTo: pinKey).count().get();
    
    if(result.count > 0) {
      return true;
    }else {
      return false;
    }
  }

  Future<void> setPinSaved(BuildContext context, String firebaseId, String pinKey, bool status) async {
    if(status) {
      _firestore.collection('users').doc(firebaseId).collection('saved_pins').doc().set({
        'pin_key': pinKey,
        'timestamp': DateTime.now().toUtc()
      }).onError((error, stackTrace) => showToastV2(context: context, msg: "An error has occurred."));
    }else {
      var spRef = await _firestore.collection('users').doc(firebaseId).collection('saved_pins').where('pin_key', isEqualTo: pinKey).get();
      spRef.docs.first.reference.delete().onError((error, stackTrace) => showToastV2(context: context, msg: "An error has occurred."));
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getConvoDoc(List<String> owners) async { 
    owners.sort((a,b) => a.compareTo(b));
    String conversationUIDString = owners.join(":");
    var result = await _firestore.collection('conversations').doc(conversationUIDString).get();

    return result;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getConvoMessagesStream(List<String> owners) async {
    owners.sort((a,b) => a.compareTo(b));
    String conversationUIDString = owners.join(":");

    var conversation = await _firestore.collection('conversations').doc(conversationUIDString).collection('messages').orderBy('timestamp', descending: true).get();

    return conversation;
  }

  Future<void> ratePinNotification(BuildContext context, Map<String, dynamic>? data) async {
    Map<String, dynamic> notiData = {};
    var results = await getUserFromFirebaseId(FirebaseAuth.instance.currentUser!.uid);
    notiData['rating_by'] = json.encode(results);

    if(data != null) notiData['rating_data'] = json.encode(data);

    if(results['user_key'] != data!['user_key'].toString()) {
      sendNotification(
        context,
        "rate_pin",
        notiData,
        userKey: data['user_key'].toString()
      );
    }
  }
}