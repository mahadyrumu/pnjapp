import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:parknjet_app/views/request_pickup/create_request_pickup.dart';
import 'package:parknjet_app/views/reservation/reservation_details.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Reservations extends StatefulWidget {
  const Reservations({super.key});

  @override
  State<Reservations> createState() => _ReservationsState();
}

class _ReservationsState extends State<Reservations>
    with WidgetsBindingObserver {
  final ReservationController reservationController =
      Get.put(ReservationController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleRefresh();
    }
  }

  Future<void> _launchUrl() async {
    String? token = await GetToken.getToken();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    final Uri _url = Uri.parse(
        'https://plg.parknjetseatac.com/redirect-from-app?url=reservation&token=$token&id=$userId');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _handleRefresh() async {
    await reservationController.refreshReservations();
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Obx(() {
          return AppBar(
            title: Text(
              'Reservations',
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              style: const TextStyle(
                fontFamily: 'SP PRO DISPLAY',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Get.to(() => const HomePage(),
                      transition: Transition.leftToRight);
                },
                icon: Icon(Icons.arrow_back_ios)),
            centerTitle: true,
            automaticallyImplyLeading: !reservationController
                .isLoading.value, // Hide back button when loading
          );
        }),
      ),
      body: Column(
        children: [
          Obx(() {
            if (reservationController.isLoading.value) {
              return const SizedBox.shrink(); // Hide button when loading
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton.icon(
                    onPressed: _launchUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Create New',
                      textScaler:
                          TextScaler.linear(getTextScale(currentScale, 1.65)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
          }),
          Expanded(
            child: Obx(() {
              if (reservationController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (reservationController.reservations.isEmpty) {
                return Center(
                  child: Text(
                    'No reservation made',
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                        letterSpacing: 2.0,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reservationController.reservations.length,
                  itemBuilder: (context, index) {
                    var reservation = reservationController.reservations[index];
                    String formattedPickUpTime =
                        DateFormat('MM/dd/yyyy hh:mm a')
                            .format(reservation.pickUpTime);
                    String formattedDropOfTime =
                        DateFormat('MM/dd/yyyy hh:mm a')
                            .format(reservation.dropOffTime);

                    return Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => {
                              Get.to(
                                  () => ReservationDetails(
                                        driverEmail:
                                            reservation.driverEmail.toString(),
                                        dropOffDate: reservation.dropOffTime,
                                        reservationID:
                                            reservation.rsvnId.toString(),
                                      ),
                                  transition: Transition.rightToLeft)
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: IntrinsicColumnWidth(),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            reservation.rsvnId.toString(),
                                            textScaler: TextScaler.linear(
                                                getTextScale(
                                                    currentScale, 1.55)),
                                            style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.5,
                                                  decoration:
                                                      TextDecoration.underline),
                                            ),
                                          ),
                                          reservation.claimId != 0
                                              ? GestureDetector(
                                                  onTap: () => {
                                                    // print(reservation.claimId),
                                                    // print(reservation.phone)
                                                    reservation.status !=
                                                            "CHECKED_OUT"
                                                        ? Get.to(
                                                            () =>
                                                                PickupRequestFormPage(
                                                                  claimId:
                                                                      reservation
                                                                          .claimId,
                                                                  phone:
                                                                      reservation
                                                                          .phone,
                                                                ),
                                                            transition:
                                                                Transition
                                                                    .rightToLeft)
                                                        : null
                                                  },
                                                  child: Text(
                                                    reservation.claimId
                                                        .toString(),
                                                    textScaler:
                                                        TextScaler.linear(
                                                            getTextScale(
                                                                currentScale,
                                                                1.55)),
                                                    style: GoogleFonts.roboto(
                                                      textStyle: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 1.5,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      Text(
                                        reservation.driver,
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.55)),
                                        style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        reservation.plate,
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.55)),
                                        style: GoogleFonts.roboto(
                                            letterSpacing: 1.5,
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14)),
                                      ),
                                      const SizedBox()
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 20),
                                        child: Text(
                                          formattedDropOfTime,
                                          textScaler: TextScaler.linear(
                                              getTextScale(currentScale, 1.55)),
                                          style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                              letterSpacing: 1.0,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 20),
                                        child: Text(
                                          formattedPickUpTime,
                                          textScaler: TextScaler.linear(
                                              getTextScale(currentScale, 1.55)),
                                          style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                              letterSpacing: 1.0,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          reservation.status
                                              .replaceAll('_', ' '),
                                          textScaler: TextScaler.linear(
                                              getTextScale(currentScale, 1.55)),
                                          style: GoogleFonts.roboto(
                                              letterSpacing: 1.5,
                                              textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                        ),
                                      ),
                                      const Center(
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 24.0,
                                        ),
                                      ),
                                    ],
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(width: 1.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
