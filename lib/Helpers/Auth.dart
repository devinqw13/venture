// import 'package:firebase_auth/firebase_auth.dart';

// class AuthHandler {
  
//   static Future<void> signInWithGeneric(BuildContext context, String userID, String password) async {
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text
//       );

//       FirebaseAuth.instance.

//       if (userCredential.credential != null) {
//         await getUserInfo(userCredential.user!.email);
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         showCustomDialog(
//           context: context, 
//           title: "An error has occurred", 
//           description: e.message, 
//           descAlignment: TextAlign.center,
//           buttons: {
//             "OK": {
//               "action": () => Navigator.of(context).pop(),
//               "color": accentBlue,
//               "textColor": Colors.white,
//               "alignment": TextAlign.center
//             }
//           }
//         );
//         return;
//       } else if (e.code == 'wrong-password') {
//         // print('Wrong password provided for that user.');
//         showCustomDialog(
//           context: context, 
//           title: "An error has occurred", 
//           description: e.message, 
//           descAlignment: TextAlign.center,
//           buttons: {
//             "OK": {
//               "action": () => Navigator.of(context).pop(),
//               "color": accentBlue,
//               "textColor": Colors.white,
//               "alignment": TextAlign.center
//             }
//           }
//         );
//         return;
//       }
//     }
//   }
// }