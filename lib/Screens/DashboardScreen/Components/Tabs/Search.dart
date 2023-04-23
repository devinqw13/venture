import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:venture/Helpers/PhotoHero.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:venture/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  List<Pin> suggestedPins = [];
  StreamController<String> streamController = StreamController();
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // streamController.stream.listen((s) => performSearch(s));
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    await fetchSuggestions();
    streamController.stream.listen((s) => performSearch(s));
  }

  Future<void> fetchSuggestions() async {
    var position = await LocationHandler.determineDeviceLocation();
    String latLng = "";
    if(position != null) {
      latLng = "${position.latitude},${position.longitude}";
    }

    var result = await getSuggestions(context, latLng, 50);
    setState(() => suggestedPins = result);
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

  _buildSearchSuffix() {
    if(textController.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: ZoomTapAnimation(
          onTap: () {
            if (textController.text.isNotEmpty) {
              textController.clear();
              setState(() {
                showSearchResults = false;
                searchResults = [];
              });
            }
          },
          child: Container(
            width: 40,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: ColorConstants.gray200,
                  shape: BoxShape.circle
                ),
                child: Icon(
                  Icons.close,
                  color: Get.isDarkMode ? ColorConstants.gray600 : Colors.white,
                  size: 14
                ),
              )
            ),
          )
        ),
      );
    }else {
      return null;
    }
  }

  goToPin(Pin pin) {
    PinScreen screen = PinScreen(pin: pin);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  _buildSuggested() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: 15),
        child: ListView(
          // physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Suggested Pins",
                style: TextStyle(
                  fontFamily: "CoolveticaCondensed",
                  // fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 23
                ),
              )
            ),
            SizedBox(
              height: 20,
            ),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.9
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              itemCount: suggestedPins.length,
              itemBuilder: (context, i) {
                return ZoomTapAnimation(
                  onTap: () => goToPin(suggestedPins[i]),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          // child: Container(color: Colors.red)
                          child: suggestedPins[i].featuredPhoto != null ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              // child: CachedNetworkImage(
                              //   fit: BoxFit.cover,
                              //   width: double.infinity,
                              //   imageUrl: suggestedPins[i].featuredPhoto!,
                              // )
                              child: PhotoHero(
                                tag: "searchTab-" + suggestedPins[i].featuredPhoto!,
                                photoUrl: suggestedPins[i].featuredPhoto!,
                                size: Size(double.maxFinite, double.maxFinite),
                              )
                            ) : Container(
                              child: Center(
                                child: Text(
                                  "Photo not available",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Get.isDarkMode ? ColorConstants.gray700 : Colors.grey[300],
                                borderRadius: BorderRadius.circular(5)
                              ),
                            )
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            // mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suggestedPins[i].title!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5
                                    ),
                                    RichText(
                                      maxLines: 2,
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: CustomIcon(
                                              icon: 'assets/icons/navigation.svg',
                                              size: 11,
                                              color: Colors.grey,
                                            )
                                          ),
                                          suggestedPins[i].distance != null ?
                                          TextSpan(
                                            text: " ${suggestedPins[i].distance} miles",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey
                                            )
                                          ) : TextSpan(
                                            text: " Distance not available",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey
                                            )
                                          ),
                                        ]
                                      )
                                    )
                                  ],
                                )
                              ),
                              RichText(
                                  // overflow: TextOverflow.ellipsis,
                                  // maxLines: 1,
                                  textAlign: TextAlign.end,
                                  text: TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: CustomIcon(
                                          icon: 'assets/icons/star.svg',
                                          size: 18,
                                          color: primaryOrange,
                                        )
                                      ),
                                      TextSpan(
                                        text: " ${suggestedPins[i].rating ?? 0.toInt()}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Get.isDarkMode ? Colors.white : Colors.black,
                                        )
                                      )
                                    ]
                                  )
                                )
                              
                            ],
                          )
                        )
                        // suggestedPins[i].featuredPhoto != null ?
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(5),
                        //   child: AspectRatio(
                        //     aspectRatio: 4 / 5,
                        //     child:  CachedNetworkImage(
                        //       fit: BoxFit.cover,
                        //       // width: 40,
                        //       // height: 50,
                        //       imageUrl: suggestedPins[i].featuredPhoto!,
                        //       progressIndicatorBuilder: (context, url, downloadProgress) {
                        //         return Skeleton.rectangular(
                        //           width: 40,
                        //           height: 50,
                        //           // borderRadius: 20.0
                        //         );
                        //       }
                        //     )
                        //   )
                        // ) : Container()
                      ]
                    ),
                  )
                );
              }
            )
          ],
        ),
      ),
    );
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
  //TODO: Build RECENT SEARCHES
  Widget buildRecentSearches() {
    return Container();
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
            // SliverAppBar(
            //   // backgroundColor: Colors.white.withOpacity(0.2),
            //   elevation: 0.5,
            //   shadowColor: Colors.grey,
            //   pinned: false,
            //   flexibleSpace: FlexibleSpaceBar(
            //     titlePadding: EdgeInsetsDirectional.only(
            //       bottom: 10.0,
            //     ),
            //     centerTitle: true,
            //     // titlePadding: EdgeInsets.symmetric(horizontal: 16),
            //     title: Text(
            //       'Search',
            //       // style: theme.textTheme.headline6!.copyWith(color: primaryOrange, fontWeight: FontWeight.w600),
            //       style: theme.textTheme.headline6!.copyWith(fontFamily: "CoolveticaCondensed",color: primaryOrange, fontSize: 24),
            //     ),
            //   ),
            // ),

            SliverFillRemaining(
              hasScrollBody: true,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                              suffixIcon: _buildSearchSuffix()
                            ),
                          ),
                        )
                      )
                    ),
                    !searchFocused ? 
                    // Padding(
                    //   padding: EdgeInsets.only(top: 15),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       SizedBox(
                    //         height: 20,
                    //       ),
                    //       Padding(
                    //         padding: EdgeInsets.symmetric(horizontal: 15),
                    //         child: Text(
                    //           "Suggested",
                    //           style: TextStyle(
                    //             fontFamily: "CoolveticaCondensed",
                    //             // fontWeight: FontWeight.bold,
                    //             letterSpacing: 0.5,
                    //             fontSize: 23
                    //           ),
                    //         )
                    //       ),
                    //       GridView.builder(
                    //         shrinkWrap: true,
                    //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //           crossAxisCount: 2,
                    //           mainAxisSpacing: 5.0,
                    //           crossAxisSpacing: 5.0,
                    //           childAspectRatio: 0.9
                    //         ),
                    //         itemCount: suggestedPins.length,
                    //         itemBuilder: (context, i) {
                    //           return Text(suggestedPins[i].title!);
                    //         }
                    //       )
                    //     ],
                    //   )
                    // ) 
                    _buildSuggested()
                    :
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: showSearchResults ? buildSearch() : buildRecentSearches()
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
    // KeyboardUtil.hideKeyboard(ctx);
    PinScreen screen = PinScreen(pinKey: pin.pinKey);
    Navigator.of(ctx).push(MaterialPageRoute(builder: (context) => screen));
    // Navigator.of(ctx).push(SwipeablePageRoute(
    //   canOnlySwipeFromEdge: false,
    //   builder: (BuildContext context) => screen,
    // ));
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
    // KeyboardUtil.hideKeyboard(ctx);
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