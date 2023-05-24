import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
// import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:venture/Calls.dart';
import 'package:venture/Components/Avatar.dart';
import 'package:venture/Components/Skeleton.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/LocationHandler.dart';
import 'package:venture/Helpers/PhotoHero.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/UserModel.dart';
import 'package:venture/Screens/PinScreen/PinScreen.dart';
import 'package:venture/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:venture/Controllers/Dashboard/DashboardController.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Models/VentureItem.dart';

class SearchTabV2 extends StatefulWidget {
  SearchTabV2({Key? key}) : super(key: key);

  @override
  _SearchTabV2State createState() => _SearchTabV2State();
}

class _SearchTabV2State extends State<SearchTabV2> with AutomaticKeepAliveClientMixin<SearchTabV2>, TickerProviderStateMixin {
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

  goToPin(Pin pin) {
    PinScreen screen = PinScreen(pin: pin);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  _buildSuggested() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top:0),
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
                          child: suggestedPins[i].featuredPhoto != null ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
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
                                    Text.rich(
                                      TextSpan(
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
                                      ),
                                      maxLines: 2,
                                    )
                                  ],
                                )
                              ),
                              Text.rich(
                                TextSpan(
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
                                ),
                                // overflow: TextOverflow.ellipsis,
                                // maxLines: 1,
                                textAlign: TextAlign.end,
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
        child: SliverScaffold(
          body: Column(
            children: [
              _buildSuggested()
            ],
          ),
          // body: ListView.separated(
          //   physics: const BouncingScrollPhysics(),
          //   // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          //   separatorBuilder: (_, __) => const SizedBox(height: 20),
          //   itemCount: 15,
          //   itemBuilder: (_, __) => const SizedBox(
          //     height: 100,
          //     child: DecoratedBox(
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.all(Radius.circular(20)),
          //         boxShadow: [
          //           BoxShadow(
          //             offset: Offset(0, 2),
          //             blurRadius: 6,
          //             color: Colors.black12,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // )
        )
      )
    );
  }
}

class SliverScaffold extends StatefulWidget {
  final Widget body;
  const SliverScaffold({Key? key, required this.body}) : super(key: key);

  @override
  _SliverScaffoldState createState() => _SliverScaffoldState();
}

const double _searchBarHeight = 40;
const double _searchBarVerticalMargin = 12;
const double _appBarCollapsedHeight =
    _searchBarHeight + _searchBarVerticalMargin * 2; // 78
const double _appBarExpandedHeight = 100 + _searchBarHeight; // 154

class _SliverScaffoldState extends State<SliverScaffold> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final StreamController<String> streamController = StreamController();
  final HomeController _homeController = Get.find();
  bool isSearching = false;
  bool showSearchResults = false;
  bool searchFocused = false;
  List<VentureItem> searchResults = [];

  // 0.0 -> Expanded
  double currentExtent = 0.0;
  double get minExtent => 0.0;
  double get maxExtent => _scrollController.position.maxScrollExtent;
  double get deltaExtent => maxExtent - minExtent;
  Curve get curve => Curves.easeOutCubic;

  double actionSpacing = 12;
  double iconStrokeWidth = 1.8;
  double titlePaddingHorizontal = 8;
  double titlePaddingTop = 74;
  double titleOpacity = 1.0;

  final Tween<double> actionSpacingTween = Tween(begin: 12, end: 6);
  final Tween<double> iconStrokeWidthTween = Tween(begin: 1.8, end: 1.2);
  final Tween<double> titlePaddingHorizontalTween = Tween(begin: 8, end: 40);
  final Tween<double> titlePaddingTopTween = Tween(begin: 74, end: 12);
  final Tween<double> titleOpacityTween = Tween(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  _initializeAsyncDependencies() async {
    _scrollController.addListener(_scrollListener);
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

  _scrollListener() {
    setState(() {
      currentExtent = _scrollController.offset;

      actionSpacing = _remapCurrentExtent(actionSpacingTween);
      iconStrokeWidth = _remapCurrentExtent(iconStrokeWidthTween);
      titlePaddingHorizontal = _remapCurrentExtent(titlePaddingHorizontalTween);
      titlePaddingTop = _remapCurrentExtent(titlePaddingTopTween);
      titleOpacity = _remapCurrentExtent(titleOpacityTween);
    });
  }

  double _remapCurrentExtent(Tween<double> target) {
    final double deltaTarget = target.end! - target.begin!;
    double currentTarget =
        (((currentExtent - minExtent) * deltaTarget) / deltaExtent) +
            target.begin!;
    double t = (currentTarget - target.begin!) / deltaTarget;
    double curveT = curve.transform(t);
    return ui.lerpDouble(target.begin!, target.end!, curveT)!;
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

  Widget buildSearch() {
    if(isSearching) {
      return SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(color: primaryOrange),
      );
    }else {
      return searchResults.isNotEmpty ? Column(
        children: [
          Expanded(
            child: ListView.builder(
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
            ),
          )
        ],
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
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (_, __) => [
        SliverAppBar(
          floating: true,
          pinned: true,
          leading: Row(
            children: [
              SizedBox(width: actionSpacing),
              // IconButton(
              //   onPressed: () {},
              //   splashRadius: 24,
              //   icon: Icon(IconlyLight.filter),
              // ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: titleOpacity == 1.0 ? Container() :
                  CircleAvatar(
                    radius: 16,
                    // backgroundImage: NetworkImage(photo!),
                    backgroundImage: AssetImage('assets/images/venture.png'),
                  ),
              )
            ],
          ),
          leadingWidth: 74,
          centerTitle: true,
          title: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: titleOpacity == 1.0 ? Text(
              "VENTURE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryOrange
              ),
            ) : Container()
          ),
          actions: [
            // IconButton(
            //   onPressed: () {},
            //   splashRadius: 24,
            //   icon: Icon(Icons.ac_unit),
            // ),
            FutureBuilder(
              future: FirebaseAPI().getUserFromFirebaseId(FirebaseAPI().firebaseId()!),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return ZoomTapAnimation(
                    onTap: () => _homeController.goToTab(4),
                    child: MyAvatar(
                      photo: snapshot.data!['photo_url'],
                      size: 16,
                    )
                  );
                }
                return Container();
              }
            ),
            SizedBox(width: actionSpacing),
          ],
          toolbarHeight: _appBarCollapsedHeight,
          collapsedHeight: _appBarCollapsedHeight,
          expandedHeight: _appBarExpandedHeight,
          flexibleSpace: FlexibleSpaceBar.createSettings(
            currentExtent: _appBarCollapsedHeight,
            minExtent: _appBarCollapsedHeight,
            maxExtent: _appBarExpandedHeight,
            toolbarOpacity: 1.0,
            child: FlexibleSpaceBar(
              expandedTitleScale: 1,
              stretchModes: [StretchMode.zoomBackground],
              titlePadding: EdgeInsets.only(
                top: titlePaddingTop,
                left: titlePaddingHorizontal,
                right: titlePaddingHorizontal,
              ),
              centerTitle: true,
              title: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: _searchBarHeight,
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
                            setState(() => searchFocused = true);
                          }else {
                            setState(() => searchFocused = false);
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
                            hintText: "Explore more",
                            prefixIcon: Icon(IconlyLight.search, color: Colors.grey),
                            suffixIcon: _buildSearchSuffix()
                          ),
                        ),
                      )
                    )
                  ),
                  // const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ],
      // body:  widget.body,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: !searchFocused ? widget.body :
          showSearchResults ? buildSearch() : buildRecentSearches(),
      ),
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
    // Navigator.of(ctx).push(SwipeablePageRoute(
    //   canOnlySwipeFromEdge: false,
    //   builder: (BuildContext context) => screen,
    // ));
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
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
                    photo: user.userAvatar!,
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

// class CustomFlexibleSpace extends StatefulWidget {
//   final ScrollController scrollController;
//   CustomFlexibleSpace({Key? key, required this.scrollController}) : super(key: key);

//   @override
//   _CustomFlexibleSpace createState() => _CustomFlexibleSpace();
// }

// class _CustomFlexibleSpace extends State<CustomFlexibleSpace> {
//   RxDouble titlePaddingTop = 74.0.obs;
//   RxDouble titlePaddingHorizontal = 0.0.obs;
//   final Tween<double> titlePaddingHorizontalTween = Tween(begin: 48, end: 0);
//   double opac = 1.0;

//   @override
//   void initState() {
//     super.initState();
//   }

//   _handleTitleOpacity(BuildContext ctx) {
//     final settings = ctx
//         .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
//     final deltaExtent = settings!.maxExtent - settings.minExtent;
//     final t =
//         (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
//             .clamp(0.0, 1.0);
//     final fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
//     const fadeEnd = 1.0;
//     final opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
//     opac = opacity;
//   }

//   _handleSearchResize(BuildContext context) {
    
//   }

//   double _remapCurrentExtent(BuildContext ctx, Tween<double> target) {
//     final settings = ctx
//         .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

//     final double deltaTarget = target.end! - target.begin!;

//     double deltaExtent = widget.scrollController.position.maxScrollExtent;

//     double currentTarget =
//         (((settings!.currentExtent - settings.minExtent) * deltaTarget) / deltaExtent) +
//             target.begin!;

//     double t = (currentTarget - target.begin!) / deltaTarget;

//     double curveT = Curves.easeOutCubic.transform(t);

//     return ui.lerpDouble(target.begin!, target.end!, curveT)!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (ctx, c) {
//         if(mounted) _handleTitleOpacity(ctx);
//         // _handleSearchResize(context);
//         titlePaddingHorizontal.value = _remapCurrentExtent(ctx, titlePaddingHorizontalTween);

//         return FlexibleSpaceBar(
//           expandedTitleScale: 1.0,
//           stretchModes: [StretchMode.zoomBackground],
//           centerTitle: true,
//           titlePadding: EdgeInsets.only(
//             left: titlePaddingHorizontal.value,
//             right: titlePaddingHorizontal.value,
//           ),
//           title: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 15),
//             child: Container(
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Get.isDarkMode ? ColorConstants.gray600 : Colors.white,
//                 borderRadius: BorderRadius.circular(50),
//                 boxShadow: [
//                   BoxShadow(color: Colors.grey.withOpacity(0.3), offset: Offset(0,1.5),
//                   blurRadius: 2
//                   ),
//                 ]
//               ),
//               child: Focus(
//                 onFocusChange: (hasFocus) {
//                   // if(hasFocus) {
//                   //   List<String> x = ["\"John Doe\"", "\"Kansas\""];

//                   //   setState(() => hintText = x[math.Random().nextInt(x.length)]);

//                   //   timer = Timer.periodic(Duration(seconds: 4), (Timer t) => hintTextCarousel(x));

//                   //   setState(() => searchFocused = true);

//                   //   // if(controller.position.pixels == controller.position.minScrollExtent) {
//                   //   //   controller.animateTo(
//                   //   //     controller.position.maxScrollExtent,
//                   //   //     duration: Duration(milliseconds: 500),
//                   //   //     curve: Curves.fastOutSlowIn,
//                   //   //   );
//                   //   // }
//                   // }else {
//                   //   setState(() => searchFocused = false);
//                   //   timer!.cancel();
//                   //   setState(() => hintText = "");
//                   // }
//                 },
//                 child: TextField(
//                   // controller: textController,
//                   textInputAction: TextInputAction.search,
//                   onSubmitted: (text) {
//                     KeyboardUtil.hideKeyboard(context);
//                   },
//                   onChanged: (value) {
//                     // if (value.isEmpty) {
//                     //   setState(() {
//                     //     searchResults = [];
//                     //     showSearchResults = false;
//                     //   });
//                     // } else {
//                     //   streamController.add(value);
//                     //   showSearchResults = true;
//                     // }
//                   },
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//                     // hintText: "Search $hintText",
//                     hintText: "Search",
//                     prefixIcon: Icon(IconlyLight.search, color: Colors.grey),
//                     // suffixIcon: _buildSearchSuffix()
//                   ),
//                 ),
//               )
//             )
//           ),
//         );
//       }
//     );
//   }
// }