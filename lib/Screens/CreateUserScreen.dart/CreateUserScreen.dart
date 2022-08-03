import 'package:flutter/material.dart';
import 'package:venture/Components/DismissKeyboard.dart';
import 'package:iconly/iconly.dart';
import 'package:venture/Constants.dart';
import 'package:venture/Helpers/Keyboard.dart';
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
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;
  FToast? fToast;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast!.init(context);
  }

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');

    setState(() {
      _isPasswordEightCharacters = false;
      if(password.length >= 8) _isPasswordEightCharacters = true;

      _hasPasswordOneNumber = false;
      if(numericRegex.hasMatch(password)) _hasPasswordOneNumber = true;
    });
  }

  _createUser() {
    KeyboardUtil.hideKeyboard(context);
    if(pwdTextController.text.isEmpty || pwdRepeatTextController.text.isEmpty) {
      promptMatchingPwdError("Password fields must not be empty.");
      return;
    }

    if(!_isPasswordEightCharacters || !_hasPasswordOneNumber) {
      promptMatchingPwdError("Password does not follow all criteria.");
      return;
    }

    if(pwdTextController.text != pwdRepeatTextController.text) {
      promptMatchingPwdError("The password fields doesn't match.");
      return;
    }

    
  }

  promptMatchingPwdError(String msg) async {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close),
          SizedBox(width: 12.0),
          Text(msg),
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
              leading: IconButton(
                icon: Icon(Icons.close, size: 28),
                onPressed: () => Navigator.of(context).pop(),
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
                      style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade600),),
                    SizedBox(height: 30,),
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
                            color: _isPasswordEightCharacters ?  Colors.green : Colors.transparent,
                            border: _isPasswordEightCharacters ? Border.all(color: Colors.transparent) :
                              Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Center(child: Icon(Icons.check, color: Get.isDarkMode ? ColorConstants.gray900 : Colors.grey.shade50, size: 15)),
                        ),
                        SizedBox(width: 10,),
                        Text("Contains at least 8 characters")
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
                    ElevatedButton(
                      onPressed: () => _createUser(),
                      child: Text("Create Account"),
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