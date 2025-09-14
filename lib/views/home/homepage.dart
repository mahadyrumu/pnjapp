import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/api/auth/google_signin_api.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/drivercontroller.dart';
import 'package:parknjet_app/controllers/prepaid_package_controller.dart';
import 'package:parknjet_app/controllers/quotes_controller.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/controllers/session_controller.dart';
import 'package:parknjet_app/controllers/user_controller.dart';
import 'package:parknjet_app/controllers/vehicle_controller.dart';
import 'package:parknjet_app/models/reservations/reservations.dart';
import 'package:parknjet_app/views/check_availability/check_availability.dart';
import 'package:parknjet_app/views/direction/direction.dart';
import 'package:parknjet_app/views/faq/faq.dart';
import 'package:parknjet_app/views/prepaid_packages/prepaid_packages.dart';
import 'package:parknjet_app/views/profile/profile.dart';
import 'package:parknjet_app/views/request_pickup/create_request_pickup.dart';
import 'package:parknjet_app/views/reservation/reservations.dart';
import 'package:parknjet_app/services/referral_service.dart';
import 'package:parknjet_app/services/reservation_service.dart';
import 'package:parknjet_app/views/splash_screen/splash_screen.dart';
import 'package:parknjet_app/views/vehicle/vehicles.dart';
import 'package:parknjet_app/views/live_servation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../driver/drivers.dart';
import '../points/points.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ReservationController reservationController =
      Get.put(ReservationController());
  List<ReservationDataModel> reservations = [];
  bool isLoading = false; // Track loading state
  bool isSending = false; // Track loading for invitation
  TextEditingController emailController = TextEditingController(); // New
  String errorMessage = "";
  String successMessage = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendReferralInvitation(String email) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    setState(() {
      isSending = true;
      successMessage = "";
      errorMessage = "";
    });
    // New
    if (email == "") {
      errorMessage = "Please provide an email!";
      Navigator.pop(context);
      setState(() {
        isSending = false;
      });
    } else {
      try {
        var res = await ReferralService.sendReferralInvitation(email);
        final body = res.body;
        final json = jsonDecode(body);
        print(json);

        if (res.statusCode == 200) {
          // setState(() {
          //   successMessage = "Referral invitation sent successfully!";
          //   emailController.clear();
          //   isSending = false;
          // });
          Get.snackbar(
            "Done",
            "Referral invitation is sent!",
            colorText: Colors.green,
            backgroundColor: Colors.green[50],
            snackPosition: SnackPosition.BOTTOM,
          );
          setState(() {
            emailController.clear();
            isSending = false;
          });
          Navigator.pop(context);
        } else if (res.statusCode == 403) {
          errorMessage = json['message'].toString();

          Navigator.pop(context);
          setState(() {
            isSending = false;
          });
        } else if (res.statusCode == 422) {
          errorMessage = json['message']['email'][0].toString();
          Navigator.pop(context);
          setState(() {
            isSending = false;
          });
        } else {
          setState(() {
            errorMessage = "Failed to send referral invitation";
            isSending = false;
          });
          Navigator.pop(context);
        }

        setState(() {
          isSending = false;
        });
      } catch (e) {
        print('Error sending referral invitation: $e');

        setState(() {
          errorMessage = "Failed to send referral invitation";
          isSending = false;
        });
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    List<ReservationDataModel> fetchReservations =
        await ReservationService.fetchReservations();
    setState(() {
      reservations = fetchReservations;
      isLoading = false; // Set loading state to false on error
    });
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    bool hasActiveReservation =
        reservationController.reservations.any((reservation) {
      return reservation.status != "CANCELLED" &&
          reservation.status != "CHECKED_OUT";
    });

    int activeReservationCount = reservationController.reservations
        .where((reservation) =>
            reservation.status != "CANCELLED" &&
            reservation.status != "CHECKED_OUT")
        .length;

    Widget liveReservationsWidget = Container();
    Widget liveReservationsTextWidget = Container();

    if (hasActiveReservation) {
      liveReservationsWidget = SizedBox(
        width: MediaQuery.of(context).size.width,
        height: activeReservationCount == 1
            ? MediaQuery.of(context).size.height * 0.10
            : MediaQuery.of(context).size.height * 0.25,
        child: const LiveReservations(),
      );

      liveReservationsTextWidget = TextButton(
        onPressed: () {
          Get.to(() => const Reservations(),
              transition: Transition.rightToLeft);
        },
        child: Text(
          'See all reservations',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          centerTitle: true,
          title: Container(
            width: MediaQuery.of(context).size.width * 0.50,
            child: Image.asset('assets/images/Logo.png'),
          ),
          leading: Builder(
            builder: ((BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu),
              );
            }),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const Gap(20),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.20,
                height: 50,
                child: const Image(
                  image: AssetImage('assets/images/Logo.png'),
                )),
            ListTile(
              title: Text(
                "Make New Reservation",
                style: const TextStyle(
                    fontFamily: 'SF PRO DISPLAY',
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.80)),
              ),
              onTap: () {
                Get.to(() => const CheckAvailability(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              title: Text(
                'Pickup Request',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.80)),
                style: const TextStyle(
                    fontFamily: 'SF PRO DISPLAY',
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              onTap: () {
                Get.to(
                    () => const PickupRequestFormPage(
                          claimId: 0,
                          phone: "",
                        ),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              title: Text(
                'Prepaid Packages',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.80)),
                style: const TextStyle(
                    fontFamily: 'SF PRO DISPLAY',
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              onTap: () {
                Get.to(() => PrepaidPackages(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              title: Text(
                'FAQ',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.80)),
                style: const TextStyle(
                  fontFamily: 'SF PRO DISPLAY',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Get.to(() => const FAQ(), transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              title: Text(
                'Get Directions',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.80)),
                style: const TextStyle(
                    fontFamily: 'SF PRO DISPLAY',
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              onTap: () {
                Get.to(() => const Direction(),
                    transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              title: Text(
                'Profile',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.80)),
                style: const TextStyle(
                    fontFamily: 'SF PRO DISPLAY',
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              onTap: () {
                Get.to(() => ProfilePage(), transition: Transition.rightToLeft);
              },
            ),
            ListTile(
              title: Text(
                'Log Out',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.80)),
                style: const TextStyle(
                    fontFamily: 'SF PRO DISPLAY',
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
              onTap: () async {
                final SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.remove("token");
                sharedPreferences.remove("userId");
                try {
                  await GoogleSignInApi.signOut;
                } catch (e) {
                  print('Error signing out from Google: $e');
                }

                try {
                  await FacebookAuth.instance.logOut();
                } catch (e) {
                  print('Error logging out from Facebook: $e');
                }
                Get.delete<VehicleController>();
                Get.delete<DriverController>();
                Get.delete<PrepaidPackageController>();
                Get.delete<QuotesController>();
                Get.delete<ReservationController>();
                Get.delete<UserController>();
                final session = SessionController.instance;
                session.clearSession();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  liveReservationsWidget,
                  liveReservationsTextWidget,
                  const Gap(20),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const Reservations(),
                          transition: Transition.rightToLeft);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.only(left: 20, top: 13, bottom: 13),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 52, 177, 234), // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Image(
                                image: AssetImage(
                                    "assets/images/dashboard/reservations.png"),
                                width: 40,
                                height: 40,
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Reservations",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 52, 177, 234),
                                  ),
                                  textScaler: TextScaler.linear(
                                      getTextScale(currentScale, 1.65)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              color: Color.fromARGB(255, 52, 177, 234),
                              Icons.arrow_forward,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Gap(20),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                          () => const PickupRequestFormPage(
                                claimId: 0,
                                phone: "",
                              ),
                          transition: Transition.rightToLeft);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.only(left: 20, top: 13, bottom: 13),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 238, 98, 98), // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Image(
                                image: AssetImage(
                                    "assets/images/dashboard/request_pickup.png"),
                                width: 40,
                                height: 40,
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Request Pickup",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 238, 98, 98),
                                  ),
                                  textScaler: TextScaler.linear(
                                      getTextScale(currentScale, 1.65)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Icon(
                                color: Color.fromARGB(255, 238, 98, 98),
                                Icons.arrow_forward),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Gap(20),
                  // Points
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const Points(),
                          transition: Transition.rightToLeft);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.only(left: 20, top: 13, bottom: 13),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 234, 186, 52), // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Image(
                                image: AssetImage(
                                    "assets/images/dashboard/points.png"),
                                width: 40,
                                height: 40,
                              ),
                              Container(
                                width: 120,
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Points",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 234, 186, 52)),
                                  textScaler: TextScaler.linear(
                                      getTextScale(currentScale, 1.65)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Icon(
                                color: Color.fromARGB(255, 234, 186, 52),
                                Icons.arrow_forward),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Gap(20),
                  // Vehicles
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const Vehicles(),
                          transition: Transition.rightToLeft);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      padding:
                          const EdgeInsets.only(left: 20, top: 13, bottom: 13),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 8, 59, 213), // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Image(
                                image: AssetImage(
                                    "assets/images/dashboard/vehicles.png"),
                                width: 40,
                                height: 40,
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Vehicles",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 8, 59, 213),
                                  ),
                                  textScaler: TextScaler.linear(
                                      getTextScale(currentScale, 1.65)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Icon(
                                color: Color.fromARGB(255, 8, 59, 213),
                                Icons.arrow_forward),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // Drivers
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const Drivers(),
                          transition: Transition.rightToLeft);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          const EdgeInsets.only(left: 20, top: 13, bottom: 13),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 236, 56, 134), // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Image(
                                image: AssetImage(
                                    "assets/images/dashboard/drivers.png"),
                                width: 40,
                                height: 40,
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Drivers",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 236, 56, 134),
                                  ),
                                  textScaler: TextScaler.linear(
                                      getTextScale(currentScale, 1.65)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: const Icon(
                                color: Color.fromARGB(255, 236, 56, 134),
                                Icons.arrow_forward),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: const Text(
                      'Refer To Earn',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 10),
                    child: const Text(
                        'Invite your friends and family and earn free parking days'),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Builder(
                      builder: (context) {
                        double maxWidth = MediaQuery.of(context).size.width;
                        bool isNarrow = maxWidth < 400;
                        // bool isNarrow = constraints.maxWidth < 400;

                        return isNarrow
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 5),
                                      child: TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                  ElevatedButton(
                                    onPressed: () {
                                      isSending
                                          ? ""
                                          : sendReferralInvitation(
                                              emailController.text);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(6),
                                          child: const Text(
                                            'Invite',
                                            style: TextStyle(
                                              fontFamily: 'SF PRO DISPLAY',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(top: 5),
                                    child: TextField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                      ),
                                    ),
                                  ),
                                  errorMessage != ""
                                      ? Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            errorMessage.toString(),
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        )
                                      : Container(),
                                  Gap(10),
                                  ElevatedButton(
                                    onPressed: () {
                                      isSending
                                          ? ""
                                          : sendReferralInvitation(
                                              emailController.text);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(6),
                                          child: const Text(
                                            'Invite',
                                            style: TextStyle(
                                              fontFamily: 'SF PRO DISPLAY',
                                              fontSize: 25,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                  ),
                  const Gap(5),
                  successMessage != ""
                      ? Text(
                          successMessage.toString(),
                          style: const TextStyle(color: Colors.green),
                        )
                      : Container(),

                  const Gap(40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// }background: rgba(208, 32, 48, 1);
