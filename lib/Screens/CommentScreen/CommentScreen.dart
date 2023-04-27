import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Controllers/ThemeController.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/TimeFormat.dart';
import 'package:venture/Models/Content.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CommentScreen extends StatefulWidget {
  final String? documentId;
  final int? numOfComments;
  final Content content;
  CommentScreen({Key? key, required this.documentId, this.numOfComments = 0, required this.content}) : super(key: key);

  @override
  _CommentScreen createState() => _CommentScreen();
}

class _CommentScreen extends State<CommentScreen> {
  String? documentId;
  late int numOfComments;
  var allowPost = false.obs;
  TextEditingController textController = TextEditingController();
  final ThemesController _themeController = Get.put(ThemesController());
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    documentId = widget.documentId;
    numOfComments = widget.numOfComments ?? 0;

    textController.addListener(() {
      if(textController.text.isEmpty) {
        // setState(() => allowPost = false);
        allowPost.value = false;
      } else if(textController.text.isNotEmpty && !allowPost.value) {
        // setState(() => allowPost = true);
        allowPost.value = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    
  }

  void _dismiss() {

  }

  submitComment() async {
    if(textController.text.isEmpty) return;

    var result = await FirebaseAPI().addComment(
      context,
      documentId,
      widget.content.contentKey,
      textController.text,
      data: {
        "comment": textController.text,
        "content_key": widget.content.contentKey,
        "pin_key": widget.content.pinKey,
        "user_key": widget.content.user!.userKey.toString(),
        "documentId": documentId,
        "content_image_url": widget.content.contentUrls.first
      }
    );

    if(documentId == null) setState(() => documentId = result);

    textController.clear();
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void deleteComment(String commentId) {
    FirebaseAPI().deleteComment(documentId!, commentId);
    print("comment deleted...");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DismissKeyboard(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(IconlyLight.arrow_left, size: 25),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: Get.isDarkMode ? ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7) : ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Get.isDarkMode ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          title: Text(
            'Comments',
            style: theme.textTheme.headline6,
          )
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: FirestoreListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      query: FirebaseAPI().commentQuery(documentId),
                      pageSize: 20,
                      emptyBuilder: (context) {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Icon(Icons.chat, size: 80, color: Colors.grey.shade400,),
                              // SizedBox(height: 20,),
                              Text(
                                'Be the first to comment.'
                              ),
                            ],
                          ),
                        );
                      },
                      itemBuilder: (context, documentSnapshot) {
                        // String documentId = documentSnapshot.id;
                        var commentData = documentSnapshot.data() as Map<String, dynamic>;

                        return Slidable(
                          enabled: commentData['firebase_id'] == FirebaseAPI().firebaseId() ? true : false,
                          key: ValueKey(documentSnapshot.id),
                          endActionPane: ActionPane(
                            extentRatio: 0.15,
                            motion: const BehindMotion(),
                            dismissible: commentData['firebase_id'] == FirebaseAPI().firebaseId() ? DismissiblePane(
                              onDismissed: () => deleteComment(documentSnapshot.id)
                            ) : null,
                            children: [
                              CustomSlidableAction(
                                backgroundColor: Colors.red,
                                onPressed: (context) => deleteComment(documentSnapshot.id),
                                child: CustomIcon(
                                  icon: 'assets/icons/trash.svg',
                                  color: Colors.white,
                                  size: 35,
                                )
                              ),
                            ],
                          ),
                          child: FutureBuilder(
                            future: FirebaseAPI().getUserFromFirebaseId(commentData['firebase_id']),
                            builder: (context, snapshot) {
                              var date = DateTime.parse(commentData['timestamp'].toDate().toString()).toString();

                              if(snapshot.hasData) {
                                var docSnapshot = snapshot.data as Map<String, dynamic>;
                                var userData = docSnapshot;

                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      MyAvatar(photo: userData['photo_url']),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "${userData['username']} ",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14
                                                      )
                                                    ),
                                                    if(userData['verified'])
                                                      WidgetSpan(
                                                        child: CustomIcon(
                                                          icon: 'assets/icons/verified-account.svg',
                                                          size: 17,
                                                          color: primaryOrange,
                                                        )
                                                      ),
                                                  ]
                                                )
                                              ),
                                              // Text(
                                              //   userData['username'],
                                              //   style: TextStyle(
                                              //     fontWeight: FontWeight.bold,
                                              //     fontSize: 14
                                              //   ),
                                              // ),
                                              SizedBox(height: 7),
                                              Text(
                                                commentData['comment'],
                                                style: TextStyle(
                                                  fontSize: 16
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              TimeFormat()
                                                .withoutDate(
                                                  date,
                                                  style: TextStyle(
                                                    color: Colors.grey
                                                  )
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                );
                              }
                              return Container();
                            }
                          )
                        );
                      }
                    )
                  )
                ]
              )
            ),
            Card(
              color: _themeController.getContainerBgColor(),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.only(right: 16, left: 16, bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 15, top: 8),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              ZoomTapAnimation(
                                child: IconButton(
                                  splashRadius: 20,
                                  icon: Icon(Icons.add, color: Colors.grey.shade700, size: 28,),
                                  onPressed: () {},
                                )
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    color: Get.isDarkMode ? ColorConstants.gray600 : Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Obx(() => 
                                    TextField(
                                      controller: textController,
                                      // onChanged: (value) => setTyper(),
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (string) => submitComment(),
                                      minLines: 1,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(right: 16, left: 20, bottom: 10, top: 10),
                                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                        hintText: 'Type a message',
                                        suffixIcon: allowPost.value ? ZoomTapAnimation(
                                          child: ElevatedButton(
                                            onPressed: () => submitComment(),
                                            child: Text(
                                              "Post",
                                              style: TextStyle(
                                                color: allowPost.value ? primaryOrange : null
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              primary: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              splashFactory: NoSplash.splashFactory,
                                            )
                                          )
                                        ) : null
                                      ),
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            )
          ],
        ),
      )
    );
  }
}