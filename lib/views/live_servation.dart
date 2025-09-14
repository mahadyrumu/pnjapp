import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/views/request_pickup/create_request_pickup.dart';
import 'package:parknjet_app/views/reservation/reservation_details.dart';

class LiveReservations extends StatelessWidget {
  const LiveReservations({super.key});

  @override
  Widget build(BuildContext context) {
    final ReservationController reservationController =
        Get.put(ReservationController());
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      body: Obx(() {
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

        return ListView.builder(
          shrinkWrap: true,
          itemCount: reservationController.reservations.length,
          itemBuilder: (context, index) {
            var reservation = reservationController.reservations[index];
            String formattedPickUpTime =
                DateFormat('MM/dd/yyyy hh:mm a').format(reservation.pickUpTime);
            String formattedDropOfTime = DateFormat('MM/dd/yyyy hh:mm a')
                .format(reservation.dropOffTime);

            return reservation.status == "NEW" ||
                    reservation.status == "CHECKED_IN"
                ? Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                              () => ReservationDetails(
                                    driverEmail: reservation.driverEmail,
                                    dropOffDate: reservation.dropOffTime,
                                    reservationID:
                                        reservation.rsvnId.toString(),
                                  ),
                              transition: Transition.rightToLeft);
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
                                            getTextScale(currentScale, 1.40)),
                                        style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1.5,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                      reservation.claimId != 0
                                          ? GestureDetector(
                                              onTap: () => {
                                                Get.to(
                                                    () => PickupRequestFormPage(
                                                          claimId: reservation
                                                              .claimId,
                                                          phone:
                                                              reservation.phone,
                                                        ),
                                                    transition:
                                                        Transition.rightToLeft)
                                              },
                                              child: Text(
                                                reservation.claimId.toString(),
                                                textScaler: TextScaler.linear(
                                                    getTextScale(
                                                        currentScale, 1.40)),
                                                style: GoogleFonts.roboto(
                                                  textStyle: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 1.5,
                                                      decoration: TextDecoration
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
                                        getTextScale(currentScale, 1.40)),
                                    style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    reservation.plate,
                                    textScaler: TextScaler.linear(
                                        getTextScale(currentScale, 1.40)),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 20),
                                    child: Text(
                                      formattedDropOfTime,
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.40)),
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          letterSpacing: 1.0,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 20),
                                    child: Text(
                                      formattedPickUpTime,
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.40)),
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          letterSpacing: 1.0,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      reservation.status.replaceAll('_', ' '),
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.40)),
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
                                  border:
                                      Border(bottom: BorderSide(width: 1.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container();
          },
        );
      }),
    );
  }
}
