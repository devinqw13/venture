import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Components/ExpandableText.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Helpers/MapPreview.dart';
import 'package:venture/Models/Pin.dart';
import 'package:venture/Models/VenUser.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class PinSkeleton extends StatefulWidget {
  final Pin pin;
  final bool enableBackButton;
  PinSkeleton({Key? key, required this.pin, required this.enableBackButton}) : super(key: key);

  @override
  _PinSkeleton createState() => _PinSkeleton();
}

class _PinSkeleton extends State<PinSkeleton> {
  DraggableScrollableController dragController = DraggableScrollableController();
  double? _detailsHeight;

  @override
  void initState() {
    super.initState();

  }

  overviewBody(ScrollController controller) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      controller: controller,
      children: [
        widget.pin.description != null && widget.pin.description!.isNotEmpty ? 
        ExpandableText(
          widget.pin.description,
          trimLines: 8,
        ) :
        Text(
          "No description provided"
        ),
        SizedBox(height: 15),
        MapPreview(
          latitude: double.parse(widget.pin.latLng.split(',')[0]), longitude: double.parse(widget.pin.latLng.split(',')[1]),
          height: 150,
        )
      ],
    );
  }

  commentsBody(ScrollController controller) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: controller,
            padding: EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            itemCount: 100,
            itemBuilder: (context, i) {
              return Text(i.toString());
            },
          )
        ),
        Container(
          padding: EdgeInsets.only(bottom: 20),
          color: ColorConstants.gray50,
          child: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              hintText: "Add a comment",
            )
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            widget.enableBackButton ?
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(
                IconlyLight.arrow_left,
                color: primaryOrange,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: primaryOrange,
                primary: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.7),
                shape: CircleBorder(),
              ),
            ): Container(),
            VenUser().userKey.value == widget.pin.user!.userKey ?
            ElevatedButton(
              onPressed: () => print("CREATOR SETTINGS"),
              child: CustomIcon(
                icon: 'assets/icons/settings.svg',
                size: 27,
                color: primaryOrange,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: primaryOrange,
                primary: Get.isDarkMode ? ColorConstants.gray800 : ColorConstants.gray25.withOpacity(0.7),
                shape: CircleBorder(),
              ),
            ): Container(),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
            height: _detailsHeight ?? MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: widget.pin.featuredPhoto != null ? DecorationImage(
                image: NetworkImage(
                  widget.pin.featuredPhoto!,
                ),
                fit: BoxFit.cover
              ): null,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0, -(MediaQuery.of(context).size.height / 1200)),
                      end: Alignment(0, MediaQuery.of(context).size.height / 1100),
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6)
                      ]
                    )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              widget.pin.title!,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 2,
                              style: theme.textTheme.headline3!.copyWith(color: Colors.white),
                            )
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  CustomIcon(
                                    icon: 'assets/icons/star.svg',
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "${widget.pin.rating ?? 0.0}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "${widget.pin.totalReviews ?? 0} reviews",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      ZoomTapAnimation(
                        onTap: () => print("GO TO MAP"),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: Text(
                            "Directions",
                            style: theme.textTheme.bodyText2!.copyWith(color: Colors.white)
                          ),
                          decoration: BoxDecoration(
                            color: primaryOrange,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        )
                      )
                    ]
                  )
                ),
              ],
            )
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (d) {
              setState(() {
                _detailsHeight = MediaQuery.of(context).size.height * ((1-d.extent) + 0.05);
              });
              return true;
            } ,
            child: DraggableScrollableSheet(
              minChildSize: 0.4,
              initialChildSize: 0.4,
              maxChildSize: 0.6,
              controller: dragController,
              builder: (context, scrollController) => Stack(
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      )
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              width: 30,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: ColorConstants.gray100,
                                borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                          )
                        ),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [ 
                                TabBar(
                                  isScrollable: true,
                                  indicator: CircleTabIndicator(color: primaryOrange, radius: 3),
                                  labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                  unselectedLabelColor: Colors.black,
                                  labelColor: primaryOrange,
                                  tabs: [
                                    Tab(
                                      child: Text(
                                        "Overview",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    ),
                                    Tab(
                                      child: Text(
                                        "Comments",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      overviewBody(scrollController),
                                      commentsBody(scrollController)
                                    ],
                                  )
                                )
                              ],
                            )
                          )
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Transform.translate(
                        offset: Offset(0, -30),
                        child: ZoomTapAnimation(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              shape: BoxShape.circle
                            ),
                            child: CustomIcon(
                              icon: 'assets/icons/bookmark.svg',
                              size: 25,
                              color: Colors.white
                            ),
                          ),
                        ),
                      )
                    )
                  ),
                ]
              )
            )
          ),
        ],
      ),
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius}) : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset = offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}