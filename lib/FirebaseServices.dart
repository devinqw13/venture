import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:venture/Models/VenUser.dart';

class FirebaseServices extends ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  Stream<dynamic> getContent() {
    return _firestore.collection('pins')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<dynamic>> getReactions(String contentKey) {
    return _firestore.collection('content')
        .where('content_key', isEqualTo: contentKey)
        .snapshots()
        .map((snapShot) => snapShot.docs
        .map((document) => document.data()).toList().first['reactions']);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkUsername(String username) async {
    return _firestore.collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserDetails(String username) async {
    return _firestore.collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  Future<UserCredential?> createUserWithEmailAndPassword(BuildContext context, String username, String email, String password) async {
    UserCredential? userCredential;

    var user = await checkUsername(username);
    if(user.docs.isNotEmpty) {
      showToast(context: context, msg: "The username already exists.");
      return null;
    }

    try {
      bool? result = await createUser(context, username, email, password: password);

      if(!result) return null;

      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      if (userCredential.user != null) {

        var userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
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
      var result = await getUserDetails(user.toLowerCase());
      if(result.docs.isEmpty) {
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
        storage.write('user_key', VenUser().userKey.value);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast(context: context, msg: "User was not found.");
        return null;
      } else if (e.code == 'wrong-password') {
        showToast(context: context, msg: "Username/email or password did not match");
        return null;
      }
    }

    return userCredential;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
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