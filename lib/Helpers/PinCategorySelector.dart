import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_animations/animation_builder/custom_animation_builder.dart';
import 'package:simple_animations/movie_tween/movie_tween.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:venture/Helpers/CustomIcon.dart';
import 'package:venture/Models/PinCategory.dart';
import 'package:simple_animations/simple_animations.dart' as sa;

Future<PinCategory?> showPinCategorySelectorSheet({
  required BuildContext context,
  PinCategory? initCategory
}) async {
  var response = await Get.bottomSheet(
    CategorySelector(initCategory: initCategory),
    enableDrag: false
  );
  return response;
}

class CategorySelector extends StatefulWidget {
  final PinCategory? initCategory;
  CategorySelector({Key? key, this.initCategory}) : super(key: key);

  @override 
  _CategorySelector createState() => _CategorySelector();
}

class _CategorySelector extends State<CategorySelector> {
  List<PinCategory> categories = [];
  int selectedIndex = -1;
  PinCategory? _selection;
  RxBool isLoading = false.obs;
  // RxBool _visible = false.obs;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() {
    categories = globals.defaultPinCategories;
    if(widget.initCategory != null) {
      int index = categories.indexWhere((e) => e == widget.initCategory);
      setState(() {
        selectedIndex = index;
        _selection = widget.initCategory;
      });
    }
  }

  submit() {
    Get.back(result: _selection);
  }

  categoryContainer(PinCategory category, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedIndex == index) {
            selectedIndex = -1;
            _selection = null;
            // _visible.value = false;
          }else {
            selectedIndex = index;
            _selection = category;
            // _visible.value = true;
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: selectedIndex == index ? 
            primaryOrange.withOpacity(0.4) :
            Get.isDarkMode ? ColorConstants.gray500 : Colors.grey.shade100,
          border: Border.all(
            color: selectedIndex == index ? 
            primaryOrange : Get.isDarkMode ? ColorConstants.gray500 : Colors.grey.shade100,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomIcon(
              icon: category.iconPath,
              color: Get.isDarkMode ? Colors.white : Colors.black,
              size: 75,
            ),
            SizedBox(height: 20),
            Text(category.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 20))
          ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        submit();
        return Future.value(false);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        // height: MediaQuery.of(context).size.height * 0.23,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 30,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: ColorConstants.gray100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Select a category",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Select a category that best fit the pin.",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                  ),
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FadeAnimation(delay: (1.0 + index) / 4, child: categoryContainer(categories[index], index));
                    // return Container();
                  }
                ),
              ),
              // SizedBox(height: 15),
              // Obx(() => Padding(
              //   padding: EdgeInsets.symmetric(vertical: 10),
              //   child: AnimatedOpacity(
              //     opacity: _visible.value ? 1.0 : 0.0,
              //     duration: const Duration(milliseconds: 500),
              //     child: ElevatedButton(
              //       onPressed: () => _visible.value ? submit() : null,
              //       child: Text("Submit"),
              //       style: ElevatedButton.styleFrom(
              //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //         // padding: EdgeInsets.all(0),
              //         // minimumSize: Size.zero,
              //         minimumSize: Size(
              //           150, 40
              //         ),
              //         elevation: 0,
              //         backgroundColor: primaryOrange,
              //         shadowColor: Colors.transparent,
              //         splashFactory: NoSplash.splashFactory,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20),
              //         )
              //       ),
              //     ),
              //   ),
              // ))
            ],
          )
        )
      )
    );
  }
}

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation({Key? key, required this.delay, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween('opacity', Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500))
      ..tween('translateY', Tween(begin: -30.0, end: 0.0),
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

    return CustomAnimationBuilder(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.get('opacity'),
        child: Transform.translate(
          offset: Offset(0, value.get('translateY')),
          child: child
        ),
      ),
    );
  }
}