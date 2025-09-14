import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parknjet_app/api/auth/auth.dart';
import 'package:parknjet_app/api/auth/google_signin_api.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialLogin {
  static Future<void> facebookLogin(context) async {
    final ReservationController reservationController =
        Get.put(ReservationController());
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
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
          Navigator.pop(context);

          // final profile = await fb.getUserProfile(); // get profile of user
          // final imageUrl =
          //     await fb.getProfileImageUrl(width: 100); // get user profile image
          // final email = await fb.getUserEmail(); // get user's email address

          // print('Hello, ${profile!.name}! You ID: ${profile.userId}');
          // print('Your profile image: $imageUrl');
          // if (email != null) print('And your email is $email');

          //push to success page after successfully signed in
          await reservationController.fetchReservations();
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

  static Future<void> googleSignUp(context) async {
    final ReservationController reservationController =
        Get.put(ReservationController());
    try {
      // Show the progress indicator
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      var user = await GoogleSignInApi.login();
      GoogleSignInAuthentication? googleSignInAuthentication =
          await user?.authentication;

      print(googleSignInAuthentication!.accessToken);
      var token = googleSignInAuthentication.accessToken.toString();

      // call the auth token api
      await AuthApi.authToken("mobile", "google", token);

      print(user);

      if (user != null) {
        // Close the progress indicator dialog
        Navigator.pop(context);

        // Navigate to the home page
        // ignore: use_build_context_synchronously
        // await reservationController.fetchReservations();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (error) {
      // Close the progress indicator dialog
      Navigator.pop(context);

      print(error);
    }
  }

  static Future<void> appleSignUp(BuildContext context) async {
    final ReservationController reservationController =
        Get.put(ReservationController());
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          redirectUri:
              Uri.parse('https://plg.parknjetseatac.com/b/callback/apple'),
          clientId: 'com.parknjet.dispatch-service',
        ),
      );

      String token = credential.identityToken!;
      print('Token: $token');
      await AuthApi.authToken("mobile", "sign-in-with-apple", token);

      Navigator.pop(context);

      // print(jsonEncode(userData));

      await reservationController.fetchReservations();
      // Navigate to the home page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (error) {
      Navigator.pop(context); // Ensure the dialog is closed in case of error
      print('Error during Apple sign up: $error');
    }
  }
}
