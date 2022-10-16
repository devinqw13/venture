import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venture/Models/VenUser.dart';

class Message {
  String? id;
  String? userKey;
  // String? fromName;
  // String? toName;
  // String? fromEmail;
  // String? toEmail;
  bool? isMessageRead;
  late String messageText;
  late String timestamp;
  late bool isSender;

  Message(DocumentSnapshot doc) {
    id = doc.id;
    userKey = doc.get('user_key') ?? '';
    // fromName = doc.get('from_name') ?? '';
    // toName = doc.get('to_name') ?? '';
    // fromEmail = doc.get('from_email');
    // toEmail = doc.get('to_email');
    isMessageRead = doc.get('read');
    messageText = doc.get('message');
    timestamp = doc.get('timestamp');
    isSender = userKey == VenUser().userKey.value.toString();
  }

  // MessageObject.fromJson(Map<String, dynamic> json) {
  //   this.name = json['username'];
  //   this.email = json['email'];
  //   this.phone = json['phone'];
  //   this.imageUrl = json['imageUrl'];
  //   this.isMessageRead = json['isMessageRead'];
  //   this.messageText = json['message'];
  //   this.timestamp = json['timestamp'];
  // }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['username'] = this.name;
  //   data['email'] = this.email;
  //   data['phone'] = this.phone;
  //   data['imageUrl'] = this.imageUrl;
  //   data['isMessageRead'] = this.isMessageRead;
  //   data['message'] = this.messageText;
  //   data['timestamp'] = this.timestamp;
  //   return data;
  // }
}