import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/NavigationSlideAnimation.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Models/Conversation.dart';
import 'package:venture/Models/Message.dart';
import 'package:venture/Screens/MessagingScreen/CreateConversationScreen.dart';
import 'package:venture/Screens/MessagingScreen/MessagingScreen.dart';
import 'package:venture/Screens/MessagingScreen/Components/ConversationItem.dart';

class ConversationScreen extends StatefulWidget {

  ConversationScreen({
    Key? key
  }) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  GlobalKey<MessagingScreenState> messagingDetailKey = GlobalKey<MessagingScreenState>();
  List<QueryDocumentSnapshot> conversations = [];

  @override
  void initState() {
    super.initState();

  }

  Conversation getConversationFromSnapshot(QueryDocumentSnapshot convo, QuerySnapshot snapshot) {
    List<String> ownersList = [];
    List<String> typersList = [];
    Map<String, dynamic> ownersMap = {};
    String? fromName;
    var owners = convo.get('owners');
    if (owners is List) {
      ownersList = List<String>.from(owners);
    }
    else if (owners is Map) {
      ownersMap = Map<String, dynamic>.from(owners);
      ownersList = List<String>.from(ownersMap.keys);
      var fromOwner = ownersList.firstWhere((owner) => owner.toLowerCase().trim() != VenUser().userKey.value.toString().toLowerCase().trim(), orElse: () => ""); 
      if (fromOwner.isNotEmpty) {
        if (ownersMap[fromOwner].containsKey('name')) {
          fromName = ownersMap[fromOwner]['name'];
        }
      }
    }
    ownersList.sort((a,b) => a.compareTo(b));
    List<Message> messagesList = [];
    for (var message in snapshot.docs) {
      messagesList.add(Message(message));
    }
    Map convoMap = convo.data() as Map;
    if(convoMap.containsKey('typers')) {
      var typers = convo.get('typers');
      if (typers is List) {
        typersList = List<String>.from(typers);
      }
    }
    messagesList.sort((a,b) => a.timestamp.compareTo(b.timestamp));
    bool showUnread = false;
    if (messagesList.firstWhereOrNull((message) => message.userKey == VenUser().userKey.value.toString() && !message.isMessageRead!) != null) {
      showUnread = true;
    } else {
      showUnread = false;
    }
    Conversation conversation = Conversation(owners: ownersList, typers: typersList, messages: messagesList, showUnread: showUnread, conversationUID: convo.id, fromName: fromName);
    var otherUser = ownersList.firstWhere((owner) => owner.trim().toLowerCase() != VenUser().userKey.value.toString().trim().toLowerCase(), orElse: () => "");
    if (otherUser != "") {
      if (ownersMap.containsKey(otherUser)) {
        conversation.photoUrl = ownersMap[otherUser]['photo_url'];
      }
    }
    return conversation;
  }

  goToCreateConversation() {
    CreateConversationScreen screen = CreateConversationScreen(conversations: conversations, messagingDetailKey: messagingDetailKey);
    Navigator.of(context).push(SlideUpDownPageRoute(page: screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToCreateConversation(),
        elevation: 3,
        backgroundColor: primaryOrange,
        child: CustomIcon(
          icon: 'assets/icons/edit.svg',
          color: Colors.white,
          size: 30
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Conversations', 
          // style: TextStyle(
          //   color: primaryOrange,
          // )
          style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.w600)
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: primaryOrange, size: 25),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // IconButton(
          //   splashRadius: 20,
          //   icon: Icon(IconlyLight.search, color: Colors.black, size: 22,),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 20),
          // StoryList(),
          // SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Messages", style: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('conversations').where('owners', arrayContains: VenUser().userKey.value.toString()).orderBy('last_updated', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                conversations = querySnapshot.docs;

                if (conversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("Tap the + button to start a new conversation",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16)
                      ),
                    ),
                  );
                }
                
                return ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0, bottom: 10),
                  children: [
                    for (var convo in conversations)
                    StreamBuilder(
                      stream: convo.reference.collection('messages').orderBy('timestamp', descending: true).limit(1).snapshots(),
                      builder: (context, messageSnapshot) {
                        if (!messageSnapshot.hasData || !snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                            ),
                          );
                        } else {
                          QuerySnapshot messageQuerySnapshot = messageSnapshot.data as QuerySnapshot;
                          Conversation conversation = getConversationFromSnapshot(convo, messageQuerySnapshot);
                          if (messagingDetailKey.currentState != null) {
                            if (unorderedEq(conversation.owners, messagingDetailKey.currentState!.owners)) {
                              messagingDetailKey.currentState!.updateMessages(conversation.messages);
                              // messagingDetailKey.currentState!.markMessagesAsRead();
                            }
                          }
                          return ConversationItem(conversation: conversation, detailScreenKey: messagingDetailKey, key: conversation.key, owners: conversation.owners!);
                        }
                      },
                    )
                  ]
                );
              }
            }
          )
        ],
      ),
    );
  }
}