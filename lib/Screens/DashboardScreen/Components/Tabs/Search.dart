import 'package:flutter/material.dart';
import 'package:venture/Constants.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

class SearchTab extends StatefulWidget {
  SearchTab({Key? key}) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with AutomaticKeepAliveClientMixin<SearchTab> {
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print("SEARCH SCREEN");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? ColorConstants.gray600 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10)
              ),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  hintText: "Search",
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(
                        child: Icon(IconlyLight.filter, color: Colors.grey,),
                      ),
                    ),
                  )
                ),
              ),
            )
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // _buildOfferCarousel(context),
              // _buildOfferIndicator(),
              // SizedBox(height: 16,),
              // _buildSection('Top Categories', theme),
              // SizedBox(height: 8,),
              // _buildCategories(theme),
              // SizedBox(height: 16,),
              // _buildSection('Discounts', theme),
              // SizedBox(height: 8,),
              // _buildDiscountedProducts(theme)
            ]),
          ),
        ],
      )
    );
  }
}