import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:venture/Constants.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SearchTab extends StatefulWidget {
  SearchTab({Key? key}) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with AutomaticKeepAliveClientMixin<SearchTab> {
  final TextEditingController textController = TextEditingController();
  List<SearchFilter> filters = [
    SearchFilter(name: "All", isSelected: true),
    SearchFilter(name: "Nature"),
    SearchFilter(name: "Hiking"),
    SearchFilter(name: "Best Views"),
    SearchFilter(name: "Other 1"),
    SearchFilter(name: "Other 2")
  ];
  String hintText = "";
  Timer? timer;
  bool searchFocused = false;
  ScrollController controller = ScrollController();
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
  }

  hintTextCarousel(List<String> x) {
    if(x.contains(hintText)) {
      int index = x.indexOf(hintText);
      index = index == x.length-1 ? -1 : x.indexOf(hintText);
      setState(() => hintText = x[index+1]);
    } else {
      setState(() => hintText = x.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: DismissKeyboard(
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0.5,
              shadowColor: Colors.grey,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsetsDirectional.only(
                  bottom: 10.0,
                ),
                centerTitle: true,
                // titlePadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Search',
                  style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: true,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Get.isDarkMode ? ColorConstants.gray600 : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.3), offset: Offset(0,1.5),
                            blurRadius: 2
                            ),
                          ]
                        ),
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            if(hasFocus) {
                              List<String> x = ["\"John Doe\"", "\"Kansas\""];

                              setState(() => hintText = x[Random().nextInt(x.length)]);

                              timer = Timer.periodic(Duration(seconds: 4), (Timer t) => hintTextCarousel(x));

                              setState(() => searchFocused = true);

                              if(controller.position.pixels == controller.position.minScrollExtent) {
                                controller.animateTo(
                                  controller.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.fastOutSlowIn,
                                );
                              }
                            }else {
                              setState(() => searchFocused = false);
                              timer!.cancel();
                              setState(() => hintText = "");
                            }
                          },
                          child: TextField(
                            controller: textController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (text) {
                              KeyboardUtil.hideKeyboard(context);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                              hintText: "Search $hintText",
                              prefixIcon: Icon(IconlyLight.search, color: Colors.grey),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ZoomTapAnimation(
                                  onTap: () {
                                    KeyboardUtil.hideKeyboard(context);
                                    if (textController.text.isNotEmpty) {
                                      
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    child: Center(
                                      child: Icon(IconlyLight.filter, color: primaryOrange),
                                    ),
                                  )
                                ),
                              )
                            ),
                          ),
                        )
                      )
                    ),
                    !searchFocused ? Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for(var item in filters)
                                  ZoomTapAnimation(
                                    onTap: () {
                                      for (var e in filters) {
                                        setState(() => e.isSelected = false);
                                      }
                                      setState(() => item.isSelected = true);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        item.name,
                                        style: theme.textTheme.bodyText2!.copyWith(color: item.isSelected ? Colors.white : Colors.black)
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.isSelected ? primaryOrange : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    )
                                  ),
                              ]
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Suggested",
                              style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                            )
                          )
                        ],
                      )
                    ) :
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            Divider(color: Colors.grey)
                          ],
                        )
                      )
                    )
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

class SearchFilter {
  bool isSelected = false;
  String name;

  SearchFilter({this.isSelected = false, required this.name});
}