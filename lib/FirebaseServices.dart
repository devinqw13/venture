import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/Dialog.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/VenUser.dart';

class FirebaseServices extends ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
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

  Future<UserCredential?> createUserWithEmailAndPassword(BuildContext context, String username, String email, String password) async {
    UserCredential? userCredential;

    var user = await checkUsername(username);
    if(user.docs.isNotEmpty) {
      showToast(context: context, msg: "The username already exists.");
      return null;
    }

    try {
      bool? result = await createUser(context, username, email);

      if(!result) return null;

      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      if (userCredential.user != null) {

        var userRef = _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
        userRef.set({
          'user_key': VenUser().userKey.value.toString(),
          'username': username,
          'display_name': null,
          'email': userCredential.user!.email,
          'firebase_id': FirebaseAuth.instance.currentUser!.uid,
          'photo_url': 'https://venture-content.s3.amazonaws.com/images/default-avatar.jpg',
          'followers': [],
          'following': [],
          'biography': null,
          'verified': false
        }, SetOptions(merge: true)).then((value) {
        }).catchError((error) {print("Failed to add message: $error");});

          //TODO: call setFirebaseToken
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(context: context, msg: "The email is already in use.");
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
        showToast(context: context, msg: "User was not found.");
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

        VenUser().userKey.value = userKey;
        VenUser().onChange();
        storage.write('user_key', VenUser().userKey.value);

      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast(context: context, msg: "User was not found.");
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
              "textColor": Colors.white,
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

  void reauthenticate() async {
    final user = FirebaseAuth.instance.currentUser;
    print(user?.providerData);
    // await user?.reauthenticateWithCredential(credential);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  String? firebaseId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> updatePassword(BuildContext context, String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      showToast(context: context, msg: "Unable to update password");
      return;
    }
    await user.updatePassword(password);
    showToast(context: context, gravity: ToastGravity.BOTTOM, msg: "Password was updated successfully!", type: ToastType.INFO);
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

  Future<void> addReactionV2(String? documentId, int contentKey) async {
    HapticFeedback.mediumImpact();

    if(documentId != null) {
      _firestore.collection('content').doc(documentId).collection('reactions').doc(FirebaseAuth.instance.currentUser!.uid).set({'timestamp': DateTime.now().toUtc()});
    }else {
      await addReactionFromKey(contentKey);
      // var rxRef = _firestore.collection('content').doc();
      // rxRef.set({
      //   'content_key': contentKey.toString(),
      //   // 'reactions': [FirebaseAuth.instance.currentUser!.uid]
      // }, SetOptions(merge: true)).then((value) {
      // }).then((value) {
      //   rxRef.collection("reactions").doc(FirebaseAuth.instance.currentUser!.uid).set({'timestamp': DateTime.now().toUtc()});
      // });
    }
  }

  Future<void> addReactionFromKey(int contentKey) async {
    var content = await _firestore.collection('content').where('content_key', isEqualTo: contentKey.toString()).get();

    if(content.docs.isNotEmpty) {
      var documentId = content.docs.first.id;
      _firestore.collection('content').doc(documentId).collection('reactions').doc(FirebaseAuth.instance.currentUser!.uid).set({'timestamp': DateTime.now().toUtc()});
    } else {
      var rxRef = _firestore.collection('content').doc();
      rxRef.set({
        'content_key': contentKey.toString(),
        // 'reactions': [FirebaseAuth.instance.currentUser!.uid]
      }, SetOptions(merge: true)).then((value) {
      }).then((value) {
        rxRef.collection("reactions").doc(FirebaseAuth.instance.currentUser!.uid).set({'timestamp': DateTime.now().toUtc()});
      });
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
    var rxRef = _firestore.collection('content').doc(documentId).collection('reactions').doc(FirebaseAuth.instance.currentUser!.uid).delete().onError((error, stackTrace) => print("Failed to remove reaction: $error"));
  }

  Query<Object?> likedByQuery(String? documentId) {
    return FirebaseFirestore.instance.collection('content').doc(documentId).collection('reactions').orderBy('timestamp', descending: true);
  }

  Query<Object?> commentQuery(String? documentId) {
    return FirebaseFirestore.instance.collection('content').doc(documentId).collection('comments').orderBy('timestamp', descending: true);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserFromFirebaseId(String id) async {
    return await _firestore.collection('users')
      .doc(id)
      .get();
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

  Future<void> addComment(String? documentId, int contentKey, String comment) async {
    // HapticFeedback.mediumImpact();

    if(documentId != null) {
      _firestore.collection('content').doc(documentId).collection('comments').doc().set({
        'timestamp': DateTime.now().toUtc(),
        'comment': comment,
        'firebase_id': FirebaseAuth.instance.currentUser!.uid
      });
    }else {
      var rxRef = _firestore.collection('content').doc();
      rxRef.set({
        'content_key': contentKey.toString(),
      }, SetOptions(merge: true)).then((value) {
      }).then((value) {
        rxRef.collection("comments").doc().set({
          'timestamp': DateTime.now().toUtc(),
          'comment': comment,
          'firebase_id': FirebaseAuth.instance.currentUser!.uid
        });
      });
    }
  }

  // void firebaseCloudMessagingListeners() async {
  //   if (Platform.isIOS) iOSPermission();

  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'high_importance_channel', // id
  //     'High Importance Notifications', // title
  //     description: 'This channel is used for important notifications.', // description
  //     importance: Importance.max,
  //   );

  //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('ic_launcher');
  //   final IOSInitializationSettings initializationSettingsIOS =
  //       IOSInitializationSettings(
  //           onDidReceiveLocalNotification: onDidReceiveLocalNotification); 
  //   final MacOSInitializationSettings initializationSettingsMacOS =
  //       MacOSInitializationSettings();
  //   final InitializationSettings initializationSettings = InitializationSettings(
  //       android: initializationSettingsAndroid,
  //       iOS: initializationSettingsIOS,
  //       macOS: initializationSettingsMacOS);
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //       onSelectNotification: selectNotification);

  //   await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  //   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //     alert: true, // Required to display a heads up notification
  //     badge: true,
  //     sound: true,
  //   );

        //TODO: set this function as its own and call in createUser
  //   _firebaseMessaging.getToken().then((token){
  //     setFirebaseToken(context, token!);
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     if (message.data.containsKey('type')) {
  //       if (message.data['type'] == 'message') {
  //         if (message.data.containsKey('owners')) {
  //           List<String> _ = message.data['owners'].toString().replaceAll(' ', '').split(',');
  //           // MessagingScreen messagingScreen = new MessagingScreen(goToConversation: true, owners: owners);
  //           // Navigator.of(context).push(MaterialPageRoute(builder: (context) => messagingScreen));
  //         }
  //       }
  //     }
  //   });

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('Got a message whilst in the foreground!');
  //     print('Message data: ${message.data}');

  //     if (message.notification != null) {
  //       print('Message also contained a notification: ${message.notification}');
  //     }
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;

  //     // If `onMessage` is triggered with a notification, construct our own
  //     // local notification to show to users using the created channel.
  //     if (notification != null && android != null) {
  //       flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             channel.id,
  //             channel.name,
  //             channelDescription: channel.description,
  //             icon: android.smallIcon,
  //             priority: Priority.max
  //             // other properties...
  //           ),
  //         )
  //       );
  //     }
  //   });
  // }

  Future<void> removeFirebaseTokens() async {
    // Find matching firebase token for current user and remove it from Firestore
    // so you don't receive push notifications on a specific device after logging out
    var userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    final storage = FlutterSecureStorage();
    String? deviceUniqueID = await storage.read(key: 'AppUID');
    var doc = await userRef.get();
    Map<String, String> tokens = Map<String, String>.from(doc.get('firebase_tokens'));
    tokens.removeWhere((key, value) => key == deviceUniqueID);

    userRef.update({
      'firebase_tokens': tokens
    }).then((value) {}).catchError((error) {print("Failed to remove firebase token: $error");});
  }
}