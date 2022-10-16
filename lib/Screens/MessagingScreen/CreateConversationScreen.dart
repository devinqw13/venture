import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:get/get.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Models/Conversation.dart';
import 'package:venture/Models/DynamicItem.dart';
import 'package:venture/Models/FirebaseUser.dart';
import 'package:venture/Models/Message.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:venture/Screens/MessagingScreen/MessagingScreen.dart';


class CreateConversationScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> conversations;
  final GlobalKey<MessagingScreenState> messagingDetailKey;
  CreateConversationScreen({
    Key? key,
    required this.conversations,
    required this.messagingDetailKey
  }) : super(key: key);

  @override
  _CreateConversationScreenState createState() => _CreateConversationScreenState();
}

class _CreateConversationScreenState extends State<CreateConversationScreen> {
  TextEditingController textController = TextEditingController();
  bool isSearching = false;
  bool showSearchResults = false;
  List<DynamicItem> searchResults = [];
  StreamController<String> streamController = StreamController();

  @override
  void initState() {
    super.initState();

    streamController.stream.listen((s) => performSearch(s));
  }

  performSearch(String text) async {
    setState(() => isSearching = true);
    List<DynamicItem>? results = await searchVenture(context, text, ["users"]);
    setState(() => isSearching = false);

    if(results != null) {
      setState(() => searchResults = results);
    }
  }

  Widget buildSearch() {
    if(isSearching) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: primaryOrange),
      );
    }else {
      return searchResults.isNotEmpty ? ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: searchResults.length,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return UserWidget(user: searchResults[i].user!, conversations: widget.conversations,  messagingDetailKey: widget.messagingDetailKey);
        }
      ) : 
      Center(
        child: Text("No results found!"),
      );
    }
  }

  Widget buildSuggested() {
    return Container();
    // return FutureBuilder(
    //   future: getSuggestions(context, ['users']),
    //   builder: (context, snapshot) {
    //     if(!snapshot.hasData) {
    //       return SizedBox(
    //         width: 30,
    //         height: 30,
    //         child: CircularProgressIndicator(color: primaryOrange),
    //       );
    //     } else {
    //       return Container();
    //     }
    //   }
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DismissKeyboard(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              forceElevated: true,
              elevation: 0.5,
              leading: IconButton(
                icon: Icon(IconlyLight.arrow_left, size: 28, color: primaryOrange),
                onPressed: () => Navigator.of(context).pop(),
              ),
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                // titlePadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'New message',
                  style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(50),
                        // boxShadow: [
                        //   BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(0,1.5),
                        //   blurRadius: 1
                        //   ),
                        // ]
                      ),
                      child: TextField(
                        autocorrect: false,
                        autofocus: true,
                        controller: textController,
                        onSubmitted: (text) {
                          KeyboardUtil.hideKeyboard(context);
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              searchResults = [];
                              showSearchResults = false;
                            });
                          } else {
                            streamController.add(value);
                            showSearchResults = true;
                          }
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                          // hintText: "",
                          prefixIcon: SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: Text("To"),
                            ),
                          ),
                        ),
                      )
                    ),
                    showSearchResults ? buildSearch() : buildSuggested()
                  ],
                )
              ),
            )
          ],
        )
      )
    );
  }
}

class UserWidget extends StatelessWidget {
  final UserModel user;
  final List<QueryDocumentSnapshot<Object?>> conversations;
  final GlobalKey<MessagingScreenState> messagingDetailKey;
  const UserWidget({Key? key, required this.user, required this.conversations, required this.messagingDetailKey}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        List<String> owners = [VenUser().userKey.value.toString(), user.userKey.toString()];
        owners.sort((a,b) => a.compareTo(b));
        Conversation? matchingConversation;
        for (var conversation in conversations) {
          List<String> ownersList = [];
          Map<String, dynamic> ownersMap = {};
          var ownersFromFirebase = conversation.get('owners');
          if (ownersFromFirebase is List) {
            ownersList = List<String>.from(ownersFromFirebase);
          }
          else if (ownersFromFirebase is Map) {
            ownersMap = Map<String, dynamic>.from(ownersFromFirebase);
            ownersList = List<String>.from(ownersMap.keys);
          }
          if (unorderedEq(owners, ownersList)) {
            var messagesSnapshot = await conversation.reference.collection('messages').get();
            matchingConversation = getConversationFromSnapshot(conversation, messagesSnapshot);
          }
        }
        if (matchingConversation != null) {
          print("RESUME PREVIOUS CONVO");
          var userSnapshot = FirebaseFirestore.instance.collection('users').where('user_key', isEqualTo: user.userKey.toString()).get();

          userSnapshot.then(
            (QuerySnapshot querySnapshot) {
              MessageUser? messageUser = MessageUser(querySnapshot.docs.first.data() as Map<dynamic, dynamic>);

              MessagingScreen messagingDetailScreen = MessagingScreen(conversation: matchingConversation!, key: messagingDetailKey, existingConvoUser: messageUser, owners: owners);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => messagingDetailScreen));
            }
          );
        } else {
          var userSnapshot = FirebaseFirestore.instance.collection('users').where('user_key', isEqualTo: user.userKey.toString()).get();

          userSnapshot.then(
            (QuerySnapshot querySnapshot) {
              MessageUser? messageUser = MessageUser(querySnapshot.docs.first.data() as Map<dynamic, dynamic>);

              List<String> conversationUKeyList = [VenUser().userKey.value.toString(), user.userKey.toString()];
              conversationUKeyList.sort((a,b) => a.compareTo(b));
              String newConversationUIDString = conversationUKeyList.join(":");

              Conversation newConversation = Conversation(owners: owners, messages: [], conversationUID: newConversationUIDString, showUnread: false, fromName: null);

              MessagingScreen messagingScreen = MessagingScreen(conversation: newConversation, newSendToUser: messageUser, key: messagingDetailKey, owners: owners);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => messagingScreen));
            }
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  MyAvatar(
                    photo: user.userAvatar != null ? user.userAvatar! : 'https://www.mtsolar.us/wp-content/uploads/2020/04/avatar-placeholder.png',
                    size: 20,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName != null && user.displayName != '' ? user.displayName! : user.userName!, style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}