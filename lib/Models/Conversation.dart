import 'package:flutter/material.dart';
import 'package:venture/Models/Message.dart';
import 'package:venture/Screens/MessagingScreen/Components/ConversationItem.dart';

class Conversation {
  List<String>? owners;
  List<Message> messages = [];
  bool? showUnread = false;
  String? conversationUID;
  String? photoUrl;
  String? fromName;
  List<String>? typers = [];
  GlobalKey<ConversationItemState> key = GlobalKey<ConversationItemState>(debugLabel: 'test');

  Conversation({
    required this.owners,
    required this.messages,
    required this.showUnread,
    this.conversationUID,
    required this.fromName,
    this.typers
  });
}