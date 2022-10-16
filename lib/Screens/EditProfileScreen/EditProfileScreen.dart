// import 'package:flutter/material.dart';
// import 'package:zoom_tap_animation/zoom_tap_animation.dart';
// import 'package:venture/Components/DismissKeyboard.dart';

// class EditProfileScreen extends StatefulWidget {
//   final int userKey;
//   EditProfileScreen({Key? key, required this.userKey}) : super(key: key);

//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return DismissKeyboard(
//       child: Scaffold(
//         body: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               leading: ZoomTapAnimation(
//                 child: Icon(Icons.close, size: 28),
//                 onTap: () => Navigator.of(context).pop(),
//               ),
//               floating: false,
//               pinned: true,
//               flexibleSpace: FlexibleSpaceBar(
//                 centerTitle: true,
//                 // titlePadding: EdgeInsets.symmetric(horizontal: 16),
//                 title: Text(
//                   'Create Your Account',
//                   style: theme.textTheme.headline6,
//                 ),
//               ),
//             ),
//           ]
//         )
//       )
//     );
//   }
// }