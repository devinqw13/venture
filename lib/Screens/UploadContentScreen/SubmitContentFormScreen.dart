import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Models/Content.dart';

class SubmitContentFormScreen extends StatefulWidget {
  final File file;
  final String contentType;
  SubmitContentFormScreen({Key? key, required this.file, required this.contentType}) : super(key: key);

  @override
  _SubmitContentFormState createState() => _SubmitContentFormState();
}

class _SubmitContentFormState extends State<SubmitContentFormScreen> {
  bool isLoading = false;
  String location = '';

  _uploadContent() async {
    if (isLoading) return;
    String path = widget.file.path;
    File file = widget.file;
    String contentName = path.substring(path.lastIndexOf('/') + 1) + '-${VenUser().userKey.value}' + '.png';
    
    setState(() => isLoading = true);
    Content? result = await handleContentUpload(context, file, VenUser().userKey.value, contentName, widget.contentType);
    setState(() => isLoading = false);

    if(result != null) {
      Navigator.of(context)..pop()..pop([result, file]);
    }
  }

  _buildPreview() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 0.4
              )
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 90
              ),
              child: Image.file(
                widget.file,
                scale: 8,
              )
            )
          ),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Write a caption.",
                // contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            )
          )
        ],
      )
    );
  }

  Widget _buildListTile(String title, String trailing, theme, {onTap, IconData? icon, Color? iconColor}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.3),
          bottom: BorderSide(color: Colors.grey, width: 0.3)
        )
      ),
      child: ZoomTapAnimation(
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Text(title, style: theme.textTheme.subtitle1),
          trailing: Container(
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trailing, style: theme.textTheme.bodyText1?.copyWith(color: Colors.grey.shade600)),
                Icon(Icons.arrow_forward_ios, size: 16,),
              ],
            ),
          ),
        )
      )
    );
  }

  _buildOptionList(ThemeData theme) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildListTile("Location",  '', theme)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.8,
          shadowColor: Colors.grey,
          leading: IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: Icon(Icons.arrow_back_ios)
          ),
          title: Text(
            'New Post',
            style: theme.textTheme.headline6,
          ),
          actions: [
            !isLoading ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: ZoomTapAnimation(
                  onTap: () => _uploadContent(),
                  child: Text("Share",
                    style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.bold),
                  ),
                )
              )
            ):
            // CircularProgressIndicator(color: primaryOrange)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: CupertinoActivityIndicator(
                radius: 13,
              )
            )
          ],
        ),
        body: Column(
          children: [
            _buildPreview(),
            Stack(
              children: [
                _buildOptionList(theme)
              ],
            )
          ],
        )
      )
    );
  }
}