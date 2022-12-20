import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/PinScreen/Components/PinSkeleton.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:venture/Screens/ProfileScreen.dart/ProfileScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Models/VentureItem.dart';

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
  bool isSearching = false;
  bool showSearchResults = false;
  List<VentureItem> searchResults = [];
  StreamController<String> streamController = StreamController();
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    streamController.stream.listen((s) => performSearch(s));
  }

  performSearch(String text) async {
    setState(() => isSearching = true);
    List<VentureItem>? results = await searchVenture(context, text, ["users", "pins"]);
    setState(() => isSearching = false);

    if(results != null) {
      setState(() => searchResults = results);
    }
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
          if(searchResults[i].user != null) {
            return UserSearched(ctx: context, user: searchResults[i].user!);
          }
          if(searchResults[i].pin != null) {
            return PinSearched(ctx: context, pin: searchResults[i].pin!);
          }

          return Container();
        }
      ) : 
      Center(
        child: Text("No results found!"),
      );
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
                            Divider(color: Colors.grey),
                            showSearchResults ? buildSearch() : Container() //TODO: show recent searches or GOTOs
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

class PinSearched extends StatelessWidget {
  final Pin pin;
  final BuildContext ctx;
  const PinSearched({Key? key, required this.pin, required this.ctx}) : super(key: key);

  goToPin() {
    KeyboardUtil.hideKeyboard(ctx);
    PinScreen screen = PinScreen(pinKey: pin.pinKey);
    Navigator.of(ctx).push(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => goToPin(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 0.1,
                          ),
                          shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 20,
                          child: CustomIcon(
                            icon: 'assets/icons/location.svg',
                            color: Get.isDarkMode ? Colors.white : Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pin.title!, style: TextStyle(fontSize: 16)),
                          //TODO: SHOW PIN LOCATION

                          // Text(
                          //   user.displayName != null && user.displayName != '' ? user.userName! : "SOMETHING HERE?",
                          //   style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey)
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}

class UserSearched extends StatelessWidget {
  final BuildContext ctx;
  final UserModel user;
  const UserSearched({Key? key, required this.ctx, required this.user}) : super(key: key);

  goToUserProfile() {
    KeyboardUtil.hideKeyboard(ctx);
    ProfileScreen screen = ProfileScreen(userKey: user.userKey!);
    Navigator.of(ctx).push(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => goToUserProfile(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  MyAvatar(
                    photo: user.userAvatar,
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

                          Text(
                            user.displayName != null && user.displayName != '' ? user.userName! : "SOMETHING HERE?",
                            style: theme.textTheme.bodyText2!.copyWith(color: Colors.grey)
                          ),
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