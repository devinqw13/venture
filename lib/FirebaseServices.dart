import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}