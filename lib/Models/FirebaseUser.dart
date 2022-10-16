import 'package:cloud_firestore/cloud_firestore.dart';

class MessageUser {
  String? username;
  String? displayName;
  String? key;
  String? firebaseID;
  String? photoUrl;

  // MessageUser(QueryDocumentSnapshot doc) {
  //   var data = doc.data() as Map;
  //   username = doc.get('username');
  //   displayName = doc.get('display_name');
  //   key = doc.get('user_key');
  //   firebaseID = doc.get('firebase_id');
  //   if (data.containsKey('photo_url')) {
  //     photoUrl = doc.get('photo_url');
  //   }
  // }

  MessageUser(Map<dynamic, dynamic> doc) {
    username = doc['username'];
    displayName = doc['display_name'];
    key = doc['user_key'];
    firebaseID = doc['firebase_id'];
    if (doc.containsKey('photo_url')) {
      photoUrl = doc['photo_url'];
    }
  }
}