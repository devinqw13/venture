import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/Conversation.dart';
import 'package:venture/Models/Message.dart';
import 'package:venture/Models/FirebaseUser.dart';
import 'package:venture/Models/VenUser.dart';

class MessagingScreen extends StatefulWidget {
  final MessageUser? newSendToUser;
  final Conversation conversation;
  final List<String>? owners; 
  final MessageUser? existingConvoUser;

  MessagingScreen({
    Key? key,
    this.newSendToUser,
    this.existingConvoUser,
    this.owners,
    required this.conversation
  }) : super(key: key);

  @override
  MessagingScreenState createState() => MessagingScreenState();
}

class MessagingScreenState extends State<MessagingScreen> {
  ScrollController _scrollController = ScrollController();
  TextEditingController textController = TextEditingController();
  List<String>? owners;
  List<Message>? messages = [];
  // late Conversation conversation;
  var isVisible = true;

  @override
  void initState() {
    super.initState();
    // conversation = widget.conversation;
    messages = widget.conversation.messages;
    if (messages!.isNotEmpty) {
      owners = widget.conversation.owners;
    }
    else {
      owners = [VenUser().userKey.value.toString(), widget.newSendToUser!.key!];
      owners!.sort((a,b) => a.compareTo(b));
    }

    if (messages!.isNotEmpty) {
      // markMessagesAsRead();
    }
  }

  // Future<void> markMessagesAsRead() async {
  //   WriteBatch batch = FirebaseFirestore.instance.batch();
  //   return FirebaseFirestore.instance.collection('conversations').doc(widget.conversation!.conversationUID).collection('messages').get().then((querySnapshot) {
  //     querySnapshot.docs.forEach((document) {
  //       if (messages!.isNotEmpty) {
  //         if (document.get('to_email') == VIPUser().email) {
  //           if (!document.get('read')) {
  //             batch.update(document.reference, {'read': true});
  //           }
  //         }
  //       }
  //     });
  //     return batch.commit();
  //   });
  // }

  updateMessages(List<Message> updatedMessages) {
    if (updatedMessages.length == messages!.length + 1) {
      messages = updatedMessages;
      rebuild();
    }
  }

  Future<bool> rebuild() async {
    if (!mounted) return false;

    // if there's a current frame,
    if (SchedulerBinding.instance!.schedulerPhase != SchedulerPhase.idle) {
      // wait for the end of that frame.
      await SchedulerBinding.instance!.endOfFrame;
      if (!mounted) return false;
    }

    // setState(() {});
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   scrollController.animateTo(
    //     scrollController.position.maxScrollExtent,
    //     duration: const Duration(milliseconds: 10),
    //     curve: Curves.easeOut,);
    //   }
    // );
    return true;
  }

  Future<void> setTyper({bool? value}) {
    if(value != null) {
      if(value) {
        FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).set({
          'typers': [VenUser().userKey.value.toString()]
        }, SetOptions(merge: true));
      }else {
        FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).set({
          'typers': []
        }, SetOptions(merge: true));
      }
    }
    if(messages!.isNotEmpty) {
      if(textController.text.isNotEmpty) {
        FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).set({
          'typers': [VenUser().userKey.value.toString()]
        }, SetOptions(merge: true));
      } else {
        FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).set({
          'typers': []
        }, SetOptions(merge: true));
      }
    }
    return Future.value(true);
  }

  Future<void> sendMessage(String message) async {
    if (messages!.isEmpty) {
      // List<String> conversationUIDList = [FirebaseAuth.instance.currentUser.uid, widget.newSendToUser.firebaseID];
      // conversationUIDList.sort((a,b) => a.compareTo(b));
      // String newConversationUIDString = conversationUIDList.join(":");

      List<String> sortedOwners = [VenUser().userKey.value.toString(), widget.newSendToUser!.key!];
      sortedOwners.sort((a,b) => a.compareTo(b));

      // Map<String, dynamic> ownersMap = {};
      // for (var owner in sortedOwners) {
      //   if (owner.toLowerCase().trim() == VIPUser().email.toLowerCase().trim()) {
      //     ownersMap[owner] = {
      //       'photo_url': FirebaseAuth.instance.currentUser!.photoURL,
      //       'name': VIPUser().name.trim()
      //     };
      //   }
      //   else {
      //     ownersMap[owner] = {
      //       'photo_url': '',
      //       'name': widget.newSendToUser!.name!.trim()
      //     };
      //   }
      // }

      FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).set({
        'owners': sortedOwners
      });

      // FirebaseFirestore.instance.collection('conversations')
      //   .add({
      //     'owners': sortedOwners
      //   })
      //   .then((newConversation) {
      //     setState(() => conversation.conversationUID = newConversation.id);

      //     FirebaseFirestore.instance.collection('conversations').doc(newConversation.id).collection('messages').add({
      //       'user_key': VenUser().userKey.value.toString(),
      //       'message': message,
      //       'timestamp': DateTime.now().toString(),
      //       'read': false
      //     }).then((value) {
      //       // Update last_updated value to store the last time the conversation was updated
      //       FirebaseFirestore.instance.collection('conversations').doc(newConversation.id).update({
      //         'last_updated': DateTime.now().toString()
      //       }).then((value) {
      //         // sendPushNotification(VIPUser().name, message);
      //       }).catchError((error) {print("Failed updating last_updated: $error");});
      //     }).catchError((error) {print("Failed to create collection and add message: $error");});
      //   });

      FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).collection('messages').add({
        'user_key': VenUser().userKey.value.toString(),
        'message': message,
        'timestamp': DateTime.now().toString(),
        'read': false
      }).then((value) {
        // Update last_updated value to store the last time the conversation was updated
        FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).update({
          'last_updated': DateTime.now().toString()
        }).then((value) {
          // sendPushNotification(VIPUser().name, message);
        }).catchError((error) {print("Failed updating last_updated: $error");});
      }).catchError((error) {print("Failed to create collection and add message: $error");});
    }
    else {
      FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).collection('messages').add({
        'user_key': VenUser().userKey.value.toString(),
        'message': message,
        'timestamp': DateTime.now().toString(),
        'read': false
      }).then((value) async {
        FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).set({
          'owners': widget.owners
        }, SetOptions(merge: true));
        // Update last_updated value to store the last time the conversation was updated
        FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).update({
          "last_updated": DateTime.now().toString()
        }).then((value) {
          // sendPushNotification(VIPUser().name, message);
        }).catchError((error) {print("Failed updating last_updated: $error");});
      }).catchError((error) {print("Failed to add message: $error");});
    }
    textController.clear();

    return Future.value(true);
  }

  buildPaginatedMessages() {
    return PaginateFirestore(
      query: FirebaseFirestore.instance.collection('conversations').doc(widget.conversation.conversationUID).collection('messages').orderBy('timestamp', descending: true),
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true, 
      reverse: true,
      itemsPerPage: 30,
      onEmpty: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
              SizedBox(height: 20,),
              Text('No messages yet'),
            ],
          ),
        ),
      ),
      // padding: const EdgeInsets.only(bottom: 90),
      itemBuilder: (context, documentSnapshot, index) {
        Message? message = Message(documentSnapshot[index]);
        // return Container();
        DateTime dateTime = DateTime.parse(message.timestamp);
        DateFormat dateFormat = DateFormat('MMM dd');
        String dateString = dateFormat.format(dateTime);
        DateFormat timeFormat = DateFormat('jm');
        String timeString = timeFormat.format(dateTime);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Align(
            alignment: message.isSender ? Alignment.topRight : Alignment.topLeft,
            child: Column(
              crossAxisAlignment: message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: message.isSender ? accentBlue : Colors.grey.shade200
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(message.messageText, style: TextStyle(fontSize: 15, color: message.isSender ? Colors.white : Colors.black))
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2),
                  child: Text(
                    dateString + " " + timeString,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal
                    )
                  ),
                ),
              ],
            )
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left, color: primaryOrange, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: ListTile(
          onTap: () {},
          leading: MyAvatar(
            photo: widget.newSendToUser != null ? widget.newSendToUser!.photoUrl : widget.existingConvoUser!.photoUrl ,
            size: 20,
          ),
          title: Text(
            widget.newSendToUser != null ? widget.newSendToUser!.displayName != null ? widget.newSendToUser!.displayName! : '@${widget.newSendToUser!.username}' : widget.existingConvoUser!.displayName != null ? widget.existingConvoUser!.displayName! : '@${widget.existingConvoUser!.username}',
            style: theme.textTheme.headline6
          ),
          // subtitle: Text('last seen yesterday at 21:05', style: theme.textTheme.bodySmall),
        ),
        actions: [
          // IconButton(
          //   splashRadius: 20,
          //   icon: Icon(Icons.videocam, color: Colors.grey.shade700,),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/video-call', arguments: chat);
          //   },
          // ),
          // IconButton(
          //   splashRadius: 20,
          //   icon: Icon(Icons.phone, color: Colors.grey.shade700,),
          //   onPressed: () {},
          // ),
        ],
      ),
      // a message list
      body: DismissKeyboard(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: buildPaginatedMessages()
                    // child: widget.conversation.messages.isNotEmpty ? ListView.builder(
                    //   reverse: true,
                    //   shrinkWrap: true,
                    //   controller: _scrollController,
                    //   padding: EdgeInsets.symmetric(vertical: 8),
                    //   itemCount: widget.conversation.messages.length,
                    //   itemBuilder: (context, index) {
                    //     return MessageWidget(
                    //       message: widget.conversation.messages[index],
                    //     );
                    //   },
                    // )
                    // : Container(
                    //   padding: EdgeInsets.symmetric(vertical: 8),
                    //   child: Center(
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
                    //         SizedBox(height: 20,),
                    //         Text('No messages yet', style: theme.textTheme.bodyText2,),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8, left: 8, bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 15 : 28, top: 8),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        splashRadius: 20,
                                        icon: Icon(Icons.add, color: Colors.grey.shade700, size: 28,),
                                        onPressed: () {},
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: TextField(
                                            controller: textController,
                                            minLines: 1,
                                            maxLines: 5,
                                            cursorColor: Colors.black,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.only(right: 16, left: 20, bottom: 10, top: 10),
                                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                              hintText: 'Type a message',
                                              border: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.grey.shade100,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                gapPadding: 0,
                                                borderSide: BorderSide(color: Colors.grey.shade200),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                gapPadding: 0,
                                                borderSide: BorderSide(color: Colors.grey.shade300),
                                              ),
                                            ),
                                            onChanged: (value) => setTyper(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      splashRadius: 20,
                                      icon: Icon(Icons.send, color: isVisible ? Colors.grey.shade700 : Colors.blue,),
                                      onPressed: () {
                                        if (textController.text.isNotEmpty) {
                                          sendMessage(textController.text);
                                          setTyper(value: false);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final Message message;
  const MessageWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.isSender) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 250
            ),
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xff1972F5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(message.messageText, style: theme.textTheme.bodyText2?.copyWith(color: Colors.white)),
                SizedBox(height: 4,),
                // Text(message.timestamp, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade300)),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 250
            ),
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(left: 8, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromARGB(255, 225, 231, 236),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.messageText, style: theme.textTheme.bodyText2),
                SizedBox(height: 4,),
                // Text(message.timestamp, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      );
    }
  }
}