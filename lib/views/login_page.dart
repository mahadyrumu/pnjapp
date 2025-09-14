import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/api/auth/auth.dart';
import 'package:parknjet_app/api/auth/signUpApi.dart';
import 'package:parknjet_app/api/social/social_login.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/controllers/session_controller.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/views/forgot_password.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  final session;
  SignUp({super.key, required this.session});

  @override
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;
  bool isChecked = false;
  bool isLoggedIn = false;
  Map userObj = {};
  late String email = "";
  late String password = "";
  String errorMessage = "";
  final ReservationController reservationController =
      Get.put(ReservationController());

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.session.username != null) {
      _emailController.text = widget.session.username.toString();
    }
    if (widget.session.password != null) {
      _passwordController.text = widget.session.password.toString();
    }
  }

  Future<void> signUp(String email, String password) async {
    errorMessage = "";
    if (_formKey.currentState?.validate() ?? false) {
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
        final singnInResponse = await ApiService.signUp(email, password);
        if (singnInResponse.success) {
          await reservationController.fetchReservations();
          Navigator.pop(context);

          // Navigate to home page or perform other actions on successful sign-up
          // ignore: use_build_context_synchronously
          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          int? userId = sharedPreferences.getInt("userId");
          String? token = await GetToken.getToken();
          final session = SessionController.instance;
          session.setSession(userId.toString(), token.toString(),
              email.toString(), password.toString());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pop(context);
          setState(() {
            errorMessage = singnInResponse.message.toString();
          });
        }
      } catch (error) {
        // Handle sign-up errors
        print('Error during sign-up: $error');
        // Show an error message or take appropriate action
      }
    }
  }

  _facebookLogin() async {
    try {
      // Create an instance of FacebookLogin
      final fb = FacebookLogin();
      // Log in
      final res = await fb.logIn(
        permissions: [
          FacebookPermission.publicProfile, // permission to get public profile
          FacebookPermission.email, // permission to get email address
        ],
      );
      // Check result status
      switch (res.status) {
        case FacebookLoginStatus.success:
          final String accessToken =
              res.accessToken!.token; // get accessToken for auth login
          print('Access token: ${accessToken}');
          await AuthApi.authToken("mobile", "facebook", accessToken);
          await reservationController.fetchReservations();
          //push to success page after successfully signed in
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => const HomePage())));

          break;
        case FacebookLoginStatus.cancel:
          // User cancel log in
          break;
        case FacebookLoginStatus.error:
          // Log in failed
          print('Error while log in: ${res.error}');
          break;
      }
    } on PlatformException catch (e) {
      print("Error during Facebook login: ${e.message}");
      // Print more detailed error information
      print("Error code: ${e.code}");
      print("Error details: ${e.details}");
    } catch (error) {
      print("Unexpected error during Facebook login: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final provider = context.watch<GoogleSignInProvider>();
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          // padding: ,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Logo.png',
                      width: 160,
                      height: 80,
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "5 minutes drive from Seatac Airport",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Gap(50),
                errorMessage != ""
                    ? Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                            child: Text(
                              errorMessage.toString(),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                              textScaler: TextScaler.linear(
                                  getTextScale(currentScale, 1.65)),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.68,
                              child: IntrinsicHeight(
                                child: TextFormField(
                                  controller: _emailController,
                                  style: TextStyle(
                                    fontSize: getHintTextScale(
                                        currentScale, 0.86, 16),
                                  ),
                                  autofillHints: [AutofillHints.username],
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(15, 5, 0, 0),
                                      filled: true,
                                      fillColor: Colors.white30,
                                      hintText: 'Email',
                                      focusColor: Colors.grey,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(width: 0.5),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0.0)),
                                      ),
                                      suffixIcon: _emailController.text != ""
                                          ? GestureDetector(
                                              onTap: () {
                                                final session =
                                                    SessionController.instance;
                                                session
                                                    .deleteSession()
                                                    .then((response) async {
                                                  setState(() {
                                                    _emailController.text = "";
                                                    _passwordController.text =
                                                        "";
                                                  });
                                                });
                                              },
                                              child: Icon(Icons.delete_forever))
                                          : null),
                                  keyboardType: TextInputType
                                      .emailAddress, // Set keyboard type for email input
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                  // Save the email input value in a variable for sign-up
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        email = value;
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 5, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                                textScaler: TextScaler.linear(
                                    getTextScale(currentScale, 1.65))),
                            const Gap(5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.68,
                              child: TextFormField(
                                controller: _passwordController,
                                style: TextStyle(
                                  fontSize:
                                      getHintTextScale(currentScale, 0.86, 16),
                                ),
                                autofillHints: [AutofillHints.password],
                                obscureText: passwordVisible,
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(15, 5, 0, 0),
                                  filled: true,
                                  fillColor: Colors.white30,
                                  hintText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                    onPressed: () {
                                      setState(
                                        () {
                                          passwordVisible = !passwordVisible;
                                        },
                                      );
                                    },
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(0.0),
                                    ),
                                    gapPadding: 3.0,
                                  ),
                                ),
                                keyboardType: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.68,
                        height: MediaQuery.of(context).size.width * 0.12,
                        child: ElevatedButton(
                          onPressed: () {
                            signUp(_emailController.text,
                                _passwordController.text);
                            TextInput.finishAutofillContext();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Log in',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      getHintTextScale(currentScale, 1.0, 16),
                                  fontWeight: FontWeight.bold),
                              textScaler: TextScaler.linear(
                                  getTextScale(currentScale, 1.45))),
                        ),
                      ),
                      const Gap(15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.68,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const ForgotPassword(),
                                transition: Transition.rightToLeft);
                          },
                          child: SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.68,
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.grey[700],
                                  fontSize: 14),
                              textScaler: TextScaler.linear(
                                  getTextScale(currentScale, 1.45)),
                              // textScaleFactor: 1.75,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                margin: const EdgeInsets.only(
                                    left: 10.0, right: 20.0),
                                child: Divider(
                                  color: Colors.grey[600],
                                  height: 36,
                                )),
                          ),
                          const Text("OR"),
                          Expanded(
                            child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20.0, right: 10.0),
                                child: Divider(
                                  color: Colors.grey[600],
                                  height: 36,
                                )),
                          ),
                        ],
                      ),
                      // SignInButton(Buttons.Google, text: "Sign in with Google",
                      //     onPressed: () {
                      //   SocialLogin.googleSignUp(context);
                      // }),
                      const Gap(5),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.12,
                        child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: () {
                            SocialLogin.googleSignUp(context);
                          },
                          child: Center(
                            child: Row(
                              children: [
                                const Gap(10),
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 25,
                                  height: 25,
                                ),
                                const Gap(10),
                                Flexible(
                                  child: Text("Continue with Google",
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 16),
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.45))),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.12,
                        child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: () {
                            SocialLogin.appleSignUp(context);
                          },
                          child: Center(
                            child: Row(
                              children: [
                                const Gap(10),
                                const Icon(
                                  Icons.apple,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                                const Gap(10),
                                Flexible(
                                  child: Text("Continue with Apple",
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 16),
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.45))),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.width * 0.12,
                      //   child: ElevatedButton(
                      //     style: OutlinedButton.styleFrom(
                      //       foregroundColor: Colors.white,
                      //       backgroundColor: Colors.blue.shade500,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(0),
                      //       ),
                      //     ),
                      //     onPressed: () {
                      //       SocialLogin.facebookLogin(context);
                      //     },
                      //     child: Center(
                      //       child: Row(
                      //         children: [
                      //           const Gap(10),
                      //           const Icon(
                      //             Icons.facebook,
                      //             color: Colors.white,
                      //             size: 25.0,
                      //           ),
                      //           const Gap(10),
                      //           Flexible(
                      //             child: Text("Continue with Meta",
                      //                 maxLines: 2,
                      //                 style: const TextStyle(fontSize: 16),
                      //                 textScaler: TextScaler.linear(
                      //                     getTextScale(currentScale, 1.45))),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const Gap(5),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
