import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Globals.dart' as globals;
import 'package:venture/Constants.dart';
import 'package:venture/FirebaseAPI.dart';
import 'package:venture/Helpers/Keyboard.dart';
import 'package:venture/Helpers/Toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateUserScreen extends StatefulWidget {
  CreateUserScreen({Key? key}) : super(key: key);

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController pwdTextController = TextEditingController();
  final TextEditingController pwdRepeatTextController = TextEditingController();
  bool obsecure = true;
  bool obsecure2 = true;
  bool _isPasswordLengthAccepted = false;
  bool _hasPasswordOneNumber = false;
  FToast? fToast;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast!.init(context);
  }

  goToPrivacyPolicy() async {
    Uri _url = Uri.parse(globals.privacyPolicy);
    if (!await launchUrl(_url)) {
      showToastV2(context: context, msg: 'Could not open link.');
    }
  }

  goToLegalTerms() async {
    Uri _url = Uri.parse(globals.legalTerms);
    if (!await launchUrl(_url)) {
      showToastV2(context: context, msg: 'Could not open link.');
    }
  }

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');

    setState(() {
      _isPasswordLengthAccepted = false;
      if(password.length >= 6) _isPasswordLengthAccepted = true;

      _hasPasswordOneNumber = false;
      if(numericRegex.hasMatch(password)) _hasPasswordOneNumber = true;
    });
  }

  bool checkFields() {
    if(usernameTextController.text.isEmpty) {
      showToast(context: context, msg: "Username field must not be empty.");
      return false;
    }
    if(usernameTextController.text.length < 5) {
      showToast(context: context, msg: "Username must be 5 or more characters.");
      return false;
    }
    if(usernameTextController.text.length > 20) {
      showToast(context: context, msg: "Username must be lower than 20 characters.");
      return false;
    }
    if(!RegExp(r'^[a-z0-9_]*$').hasMatch(usernameTextController.text)) {
      showToast(context: context, msg: "Username must be lowercase, contain no spaces or special characters except underscores (_).");
      return false;
    }

    // Email Checks
    if(emailTextController.text.isEmpty) {
      showToast(context: context, msg: "Email field must not be empty.");
      return false;
    }
    if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailTextController.text)) {
      showToast(context: context, msg: "Please enter a valid email address.");
      return false;
    }

    // Password Checks
    if(pwdTextController.text.isEmpty || pwdRepeatTextController.text.isEmpty) {
      showToast(context: context, msg: "Password fields must not be empty.");
      return false;
    }
    if(!_isPasswordLengthAccepted || !_hasPasswordOneNumber) {
      showToast(context: context, msg: "Password does not follow all criteria.");
      return false;
    }
    if(pwdTextController.text != pwdRepeatTextController.text) {
      showToast(context: context, msg: "Password fields does not match.");
      return false;
    }
    return true;
  }

  signUpWithEmail() async {
    if (isLoading) return;
    KeyboardUtil.hideKeyboard(context);
    bool canRun = checkFields();
    if (!canRun) return;

    setState(() => isLoading = true);
    var result = await FirebaseAPI().createUserWithEmailAndPassword(
      context, 
      usernameTextController.text, 
      emailTextController.text, 
      pwdTextController.text
    );
    
    if(result != null) {
      Navigator.pop(context, true);
    }

    setState(() => isLoading = false);

  }

  // _createUser() async {
  //   if (isLoading) return;
  //   KeyboardUtil.hideKeyboard(context);
  //   // Username checks
  //   if(usernameTextController.text.isEmpty) {
  //     showToast(context: context, msg: "Username field must not be empty.");
  //     return;
  //   }
  //   if(usernameTextController.text.length < 5) {
  //     showToast(context: context, msg: "Username must be 5 or more characters.");
  //     return;
  //   }
  //   if(usernameTextController.text.length > 20) {
  //     showToast(context: context, msg: "Username must be lower than 20 characters.");
  //     return;
  //   }
  //   if(!RegExp(r'^[a-zA-Z0-9_]*$').hasMatch(usernameTextController.text)) {
  //     showToast(context: context, msg: "Username must not contain spaces or special characters except underscores (_).");
  //     return;
  //   }

  //   // Email Checks
  //   if(emailTextController.text.isEmpty) {
  //     showToast(context: context, msg: "Email field must not be empty.");
  //     return;
  //   }
  //   if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailTextController.text)) {
  //     showToast(context: context, msg: "Please enter a valid email address.");
  //     return;
  //   }

  //   // Password Checks
  //   if(pwdTextController.text.isEmpty || pwdRepeatTextController.text.isEmpty) {
  //     showToast(context: context, msg: "Password fields must not be empty.");
  //     return;
  //   }
  //   if(!_isPasswordLengthAccepted || !_hasPasswordOneNumber) {
  //     showToast(context: context, msg: "Password does not follow all criteria.");
  //     return;
  //   }
  //   if(pwdTextController.text != pwdRepeatTextController.text) {
  //     showToast(context: context, msg: "Password fields does not match.");
  //     return;
  //   }

  //   setState(() => isLoading = true);
  //   bool? results = await createUser(context, usernameTextController.text, emailTextController.text, password: pwdTextController.text);

  //   if (results) {
  //     VenUser().onChange();
  //     Navigator.pop(context, true);
  //   }
  //   setState(() => isLoading = false);
  // }

  promptErrorToast(String msg) async {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.close),
          SizedBox(width: 12.0),
          Flexible(child: Text(msg)),
        ],
      ),
    );
    fToast!.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DismissKeyboard(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: ZoomTapAnimation(
                child: Icon(Icons.close, size: 28),
                onTap: () => Navigator.of(context).pop(),
              ),
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                // titlePadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Create Your Account',
                  style: theme.textTheme.headline6,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Username & email", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Please set a unique username and email that can be used to identify you.", 
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade600)),
                    SizedBox(height: 30),
                    TextField(
                      controller: usernameTextController,
                      readOnly: isLoading,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                        ),
                        hintText: "Username",
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailTextController,
                      readOnly: isLoading,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                        ),
                        hintText: "Email",
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Set a password", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Please create a secure password including the following criteria below.", 
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade600)),
                    SizedBox(height: 30),
                    TextField(
                      controller: pwdTextController,
                      readOnly: isLoading,
                      onChanged: (password) => onPasswordChanged(password),
                      obscureText: obsecure,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ZoomTapAnimation(
                            onTap: () => setState(() => obsecure = !obsecure),
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Center(
                                child: Icon(obsecure ? IconlyLight.show : IconlyLight.hide, color: Colors.grey),
                              ),
                            )
                          )
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                        ),
                        hintText: "Password",
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                    ),
                    SizedBox(height: 30,),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _isPasswordLengthAccepted ?  Colors.green : Colors.transparent,
                            border: _isPasswordLengthAccepted ? Border.all(color: Colors.transparent) :
                              Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Center(child: Icon(Icons.check, color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade50, size: 15)),
                        ),
                        SizedBox(width: 10),
                        Text("Contains at least 6 characters")
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _hasPasswordOneNumber ?  Colors.green : Colors.transparent,
                            border: _hasPasswordOneNumber ? Border.all(color: Colors.transparent) :
                              Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Center(child: Icon(Icons.check, color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade50, size: 15)),
                        ),
                        SizedBox(width: 10,),
                        Text("Contains at least 1 number")
                      ],
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: pwdRepeatTextController,
                      readOnly: isLoading,
                      obscureText: obsecure2,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ZoomTapAnimation(
                            onTap: () => setState(() => obsecure2 = !obsecure2),
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode ? ColorConstants.gray800 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Center(
                                child: Icon(obsecure2 ? IconlyLight.show : IconlyLight.hide, color: Colors.grey),
                              ),
                            )
                          )
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Get.isDarkMode ? primaryOrange : Colors.black)
                        ),
                        hintText: "Repeat Password",
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Text("Please create a secure password including the following criteria below.", 
                    //   style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade600)),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "By signing up, you agree to our "
                            ),
                            WidgetSpan(
                              child: ZoomTapAnimation(
                                onTap: () => goToLegalTerms(),
                                child: Text(
                                  "Terms",
                                  style: TextStyle(
                                    color: primaryOrange
                                  ),
                                )
                              )
                            ),
                            TextSpan(
                              text: " & "
                            ),
                            WidgetSpan(
                              child: ZoomTapAnimation(
                                onTap: () => goToPrivacyPolicy(),
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                    color: primaryOrange
                                  ),
                                )
                              )
                            ),
                          ]
                        ),
                        textAlign: TextAlign.center,
                      ))
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => signUpWithEmail(), // _createUser(),
                      child: isLoading ? 
                      SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text("Create Account"),
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        shadowColor: primaryOrange,
                        primary: primaryOrange,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )
                      ),
                    ),
                  ],
                ),
              )
            )

          ],
        ),
      )
    );
  }

}