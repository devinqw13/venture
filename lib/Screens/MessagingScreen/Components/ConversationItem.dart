import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Models/Conversation.dart';
import 'package:venture/Models/FirebaseUser.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/MessagingScreen/MessagingScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationItem extends StatefulWidget {
  final Conversation conversation;
  final GlobalKey? detailScreenKey;
  final List<String>? owners;

  ConversationItem({
    required Key? key,
    required this.conversation,
    required this.detailScreenKey,
    this.owners = const []
  }) : super(key: key);

  @override
  ConversationItemState createState() => ConversationItemState();
}

class ConversationItemState extends State<ConversationItem> {

  @override
  void initState() {
    super.initState();
    // checkIfUnread();
  }

  bool checkTypers() {
    var users = widget.conversation.typers!.where((e) => e != VenUser().userKey.value.toString());

    if(users.isNotEmpty) {
      return true;
    }else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateString = '';
    String timeString = '';
    if (widget.conversation.messages.isNotEmpty) {
      DateTime dateTime = DateTime.parse(widget.conversation.messages.last.timestamp);
      DateFormat dateFormat = DateFormat('MMM dd');
      dateString = dateFormat.format(dateTime);
      DateFormat timeFormat = DateFormat('jm');
      timeString = timeFormat.format(dateTime);
    }
    return widget.conversation.messages.isEmpty ? Container() : 
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('user_key', isEqualTo: widget.owners!.firstWhere((e) => e != VenUser().userKey.value.toString())).limit(1).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return Container();
          } else {
            QuerySnapshot userQuerySnapshot = userSnapshot.data as QuerySnapshot;
            MessageUser messageUser = MessageUser(userQuerySnapshot.docs.first.data() as Map);
            // Map userData = userQuerySnapshot.docs.first.data() as Map;
            return InkWell(
              onTap: () {
                MessagingScreen messagingDetailScreen = MessagingScreen(conversation: widget.conversation, key: widget.detailScreenKey, owners: widget.owners, existingConvoUser: messageUser);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => messagingDetailScreen));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          MyAvatar(
                            photo: messageUser.photoUrl != '' ? messageUser.photoUrl : 'https://www.mtsolar.us/wp-content/uploads/2020/04/avatar-placeholder.png',
                            size: 27,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(messageUser.displayName != null &&messageUser.displayName != '' ? messageUser.displayName! : "@${messageUser.username!}", style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 6),
                                  checkTypers() ? Text(
                                    "typing...", 
                                    style: TextStyle(
                                      fontSize: 13, 
                                      color: Colors.grey.shade600, 
                                      fontWeight: widget.conversation.showUnread! ? FontWeight.bold : FontWeight.normal
                                    )
                                  ) : Text(
                                    widget.conversation.messages.last.messageText, 
                                    style: TextStyle(
                                      fontSize: 13, 
                                      color: Colors.grey.shade600, 
                                      fontWeight: widget.conversation.showUnread! ? FontWeight.bold : FontWeight.normal
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TimeFormat().withDate(
                            widget.conversation.messages.last.timestamp,
                            numericDates: true,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: widget.conversation.showUnread! ? FontWeight.bold : FontWeight.normal
                            )
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   children: [
                          //     Text(
                          //       dateString,
                          //       style: TextStyle(
                          //         fontSize: 12,
                          //         fontWeight: widget.conversation.showUnread! ? FontWeight.bold : FontWeight.normal
                          //       )
                          //     ),
                          //     Text(
                          //       timeString,
                          //       style: TextStyle(
                          //         fontSize: 12,
                          //         fontWeight: widget.conversation.showUnread! ? FontWeight.bold : FontWeight.normal
                          //       )
                          //     ),
                          //   ],
                          // ),
                          widget.conversation.showUnread! ?
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue
                            ),
                          ) :
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            height: 10,
                            width: 10,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            );
          }
        }
    );
  }
}