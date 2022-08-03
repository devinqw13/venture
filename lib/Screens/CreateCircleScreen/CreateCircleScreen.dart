import 'package:flutter/material.dart';

class CreateCircleScreen extends StatefulWidget {
  CreateCircleScreen({Key? key}) : super(key: key);

  @override
  _CreateCircleScreenState createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              leading: IconButton(
                icon: Icon(Icons.close, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                // titlePadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Create Circle',
                  style: theme.textTheme.headline6,
                ),
              ),
            )
        ],
      ),
    );
  }

}