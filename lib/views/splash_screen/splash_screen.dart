import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/controllers/session_controller.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:parknjet_app/views/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = true;
  final ReservationController reservationController =
      Get.put(ReservationController());
  var session;

  @override
  void initState() {
    super.initState();
    session = SessionController.instance;
    session.loadSession().then((response) async {
      if (session.token != null) {
        await reservationController.fetchReservations();
        if (mounted) {
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => const HomePage())));
        }
      } else {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => SignUp(
                        session: session,
                      ))));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: Duration(seconds: 2),
            child: Image.asset(
              'assets/images/Logo.png',
              width: 160,
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}
