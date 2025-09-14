import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';
import 'package:parknjet_app/models/reservations/reservation_details.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/services/reservation_service.dart';
import 'package:parknjet_app/views/request_pickup/create_request_pickup.dart';
import 'package:parknjet_app/views/reservation/reservations.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationDetails extends StatefulWidget {
  final String driverEmail;
  final DateTime dropOffDate;
  final String reservationID;

  const ReservationDetails(
      {super.key,
      required this.driverEmail,
      required this.dropOffDate,
      required this.reservationID});

  @override
  _ReservationDetailsState createState() => _ReservationDetailsState();
}

class _ReservationDetailsState extends State<ReservationDetails>
    with WidgetsBindingObserver {
  final ReservationController reservationController =
      Get.put(ReservationController());
  ReservationDetailsDataModel? reservationDetails;
  bool isLoading = true;
  String? errorMessage;
  late Uint8List imageBytes;

  @override
  void initState() {
    super.initState();
    fetchReservationDetails();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        isLoading = true;
      });
      fetchReservationDetails();
    }
  }

  Future<void> fetchReservationDetails() async {
    try {
      String driverEmail = widget.driverEmail;
      String dropOffDate = DateFormat('yyyy-MM-dd').format(widget.dropOffDate);
      int reservationID = int.parse(widget.reservationID);
      var fetchedDetails = await ReservationService.fetchReservationDetails(
          driverEmail, dropOffDate, reservationID);

      setState(() {
        reservationDetails = fetchedDetails;
        print(reservationDetails!.saving.toString());
        isLoading = false;
        final String base64Image = reservationDetails?.qrcode;
        // Remove the "data:image/png;base64," prefix if present
        final String base64String = base64Image.split(',').last;

        // Decode the Base64 string to bytes
        imageBytes = base64Decode(base64String);
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _redirectPrePay() async {
    String? token = await GetToken.getToken();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    final Uri _url = Uri.parse(
        'https://plg.parknjetseatac.com/redirect-from-app?url=reservations/${widget.reservationID}/invoice&prepay=true&token=$token&id=$userId');

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _cancelReservation() async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      String driverEmail = widget.driverEmail;
      String dropOffDate = DateFormat('yyyy-MM-dd').format(widget.dropOffDate);
      int reservationID = int.parse(widget.reservationID);
      var cancelReservation = await ReservationService.cancelReservation(
          driverEmail, dropOffDate, reservationID);
      Navigator.of(context).pop();
      fetchReservationDetails();
      await reservationController.refreshReservations();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _printReservation() async {
    try {
      await Printing.layoutPdf(onLayout: (format) async {
        final pdf = await _generatePdf(format);
        return pdf.save();
      });
    } catch (e) {
      print('Error printing reservation: $e');
    }
  }

  Future<void> _shareReservation() async {
    try {
      final pdf = await _generatePdf(PdfPageFormat.a4);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'reservation.pdf'));
      await tempFile.writeAsBytes(await pdf.save());

      Share.shareXFiles([XFile(tempFile.path)], text: 'Reservation Details');
    } catch (e) {
      print('Error sharing reservation: $e');
    }
  }

  Future<pw.Document> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // First page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: reservationDetails!.qrcode,
                  width: 200,
                  height: 200,
                ),
              ),
              pw.SizedBox(height: 20),
              _buildPdfReservationCard(),
            ],
          );
        },
      ),
    );

    // Second page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 10),
              _buildPdfVehicleCard(),
              pw.SizedBox(height: 10),
              _buildPdfDriverCard(),
              pw.SizedBox(height: 10),
              _buildPdfPaymentCard(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfReservationCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16.0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildPdfDetailItem(
              'Reservation ID',
              reservationDetails!.rsvnId.toString(),
              reservationDetails!.phone.toString()),
          reservationDetails!.claimId != 0
              ? _buildPdfDetailItem(
                  'Claim ID',
                  reservationDetails!.claimId.toString(),
                  reservationDetails!.phone.toString(),
                )
              : pw.Container(),
          _buildPdfDetailItem(
              'Current Status',
              reservationDetails!.status.replaceAll('_', ' '),
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Parking Lot',
              reservationDetails!.lotType == "LOT_2" ? "Lot 2" : "Lot 1",
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Parking Lot Address',
              reservationDetails!.lotType == "LOT_2"
                  ? "Park N Jet Lot-2, 1244 S 140th Street, Seattle WA 98168"
                  : "Park N Jet Lot-1, 18220 8th Ave S SeaTac, WA 98148",
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Parking Lot Phone Number',
              reservationDetails!.lotType == "LOT_2"
                  ? "(206) 244-4500"
                  : "(206) 241-6600",
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Parking Preference',
              reservationDetails!.parkingPreference,
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Check In',
              _formatDate(reservationDetails!.dropOffTime),
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Check Out',
              _formatDate(reservationDetails!.pickUpTime),
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Duration of stay',
              reservationDetails!.durationInDay.toString(),
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Applied Earned/Prepaid Days',
              reservationDetails!.isPaid == true
                  ? (reservationDetails!.onlineDiscountedDay +
                              reservationDetails!.discountDays)
                          .toString() +
                      ' Days'
                  : (reservationDetails!.offlineDiscountedDay +
                              reservationDetails!.discountDays)
                          .toString() +
                      ' Days',
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Discount Amount',
              reservationDetails!.isPaid == true
                  ? '\$' + reservationDetails!.onlineDiscountAmount.toString()
                  : '\$' + reservationDetails!.offlineDiscountAmount.toString(),
              reservationDetails!.phone.toString()),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDriverCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16.0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Driver info',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 18,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildPdfDetailItem('Full Name', reservationDetails!.driverFullName,
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem('Email', reservationDetails!.email,
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem('Phone Number', reservationDetails!.phone,
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Number of people including driver',
              reservationDetails!.paxCount,
              reservationDetails!.phone.toString()),
        ],
      ),
    );
  }

  pw.Widget _buildPdfVehicleCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16.0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Vehicle info',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 18,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildPdfDetailItem('Make & Model', reservationDetails!.makeModel,
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem('License Plate', reservationDetails!.plate,
              reservationDetails!.phone.toString()),
          _buildPdfDetailItem(
              'Length',
              reservationDetails!.vehicleLength == "STANDARD"
                  ? "Under 17ft."
                  : reservationDetails!.vehicleLength == "LARGE"
                      ? "17-19ft."
                      : "19-21ft.",
              reservationDetails!.phone.toString()),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDetailItem(
    String title,
    String value,
    String phone,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value,
              overflow: pw.TextOverflow.clip,
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('EEEE, MMMM d, y hh:mm a');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Reservation Details',
            textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
          ),
          leading: IconButton(
              onPressed: () {
                Get.to(() => const Reservations(),
                    transition: Transition.leftToRight);
              },
              icon: Icon(Icons.arrow_back_ios)),
          automaticallyImplyLeading: !isLoading,
        ),
        body: PopScope(
          onPopInvoked: (bool didPop) {
            // Disable back button functionality when loading
            if (isLoading) {
              return;
            }
            // If not loading, allow the back button to pop
            Navigator.of(context).maybePop();
          },
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text('Error: $errorMessage'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Image.memory(
                                imageBytes,
                                width: 250, // Set desired width
                                height: 250, // Set desired height
                                fit: BoxFit.contain, // Ensure proper scaling
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _shareReservation,
                                  icon: const Icon(Icons.share),
                                  label: Text(
                                    'Share',
                                    textScaler: TextScaler.linear(
                                        getTextScale(currentScale, 1.65)),
                                  ),
                                ),
                                const Gap(20),
                                ElevatedButton.icon(
                                  onPressed: _printReservation,
                                  icon: const Icon(Icons.print),
                                  label: Text(
                                    'Print',
                                    textScaler: TextScaler.linear(
                                        getTextScale(currentScale, 1.65)),
                                  ),
                                ),
                              ],
                            ),
                            reservationDetails!.isPaid == false
                                ? reservationDetails!.status == "NEW"
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              iconColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 5, 15, 5),
                                              backgroundColor: Colors
                                                  .green, // Set background color to red
                                            ),
                                            onPressed: _redirectPrePay,
                                            label: reservationDetails!.saving ==
                                                    "0"
                                                ? Text(
                                                    'Pay Now: ${reservationDetails!.onlinePayNow} (SAVE \$0)',
                                                    textScaler:
                                                        TextScaler.linear(
                                                            getTextScale(
                                                                currentScale,
                                                                1.65)),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : Text(
                                                    'Pay Now: ${reservationDetails!.onlinePayNow} (SAVE \$${double.parse(reservationDetails!.saving).toStringAsFixed(2)})',
                                                    textScaler:
                                                        TextScaler.linear(
                                                            getTextScale(
                                                                currentScale,
                                                                1.65)),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          ),
                                        ],
                                      )
                                    : Container()
                                : Container(),
                            reservationDetails!.status == "NEW"
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          iconColor: Colors.white,
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          backgroundColor: Colors
                                              .redAccent, // Set background color to red
                                        ),
                                        onPressed: _cancelReservation,
                                        icon: const Icon(Icons.cancel_outlined),
                                        label: Text(
                                          'Cancel Reservation',
                                          textScaler: TextScaler.linear(
                                              getTextScale(currentScale, 1.65)),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            const SizedBox(height: 20),
                            _buildReservationCard(currentScale),
                            const SizedBox(height: 20),
                            _buildVehicleCard(currentScale),
                            const SizedBox(height: 20),
                            _buildDriverCard(currentScale),
                            const SizedBox(height: 20),
                            _buildPaymentCard(currentScale),
                          ],
                        ),
                      ),
                    ),
        ));
  }

  Widget _buildReservationCard(currentScale) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            buildDetailItem('Reservation ID',
                reservationDetails!.rsvnId.toString(), "", currentScale),
            reservationDetails!.claimId != 0
                ? buildDetailItemUnderlined(
                    'Claim ID',
                    reservationDetails!.claimId.toString(),
                    reservationDetails!.phone.toString(),
                    currentScale)
                : Container(),
            buildDetailItem(
                'Current Status',
                reservationDetails!.status.replaceAll('_', ' '),
                "",
                currentScale),
            buildDetailItem(
                'Parking Lot',
                reservationDetails!.lotType == "LOT_2" ? "Lot 2" : "Lot 1",
                "",
                currentScale),
            buildDetailItem(
                'Parking Lot Address',
                reservationDetails!.lotType == "LOT_2"
                    ? "Park N Jet Lot-2, 1244 S 140th Street, Seattle WA 98168"
                    : "Park N Jet Lot-1, 18220 8th Ave S SeaTac, WA 98148",
                "",
                currentScale),
            buildDetailItem(
                'Parking Lot Phone Number',
                reservationDetails!.lotType == "LOT_2"
                    ? "(206) 244-4500"
                    : "(206) 241-6600",
                "",
                currentScale),
            buildDetailItem('Parking Preference',
                reservationDetails!.parkingPreference, "", currentScale),
            buildDetailItem('Check In',
                _formatDate(reservationDetails!.dropOffTime), "", currentScale),
            buildDetailItem('Check Out',
                _formatDate(reservationDetails!.pickUpTime), "", currentScale),
            buildDetailItem('Duration of stay',
                reservationDetails!.durationInDay.toString(), "", currentScale),
            buildDetailItem(
                'Applied Earned/Prepaid Days',
                reservationDetails!.isPaid == true
                    ? (reservationDetails!.onlineDiscountedDay +
                                reservationDetails!.discountDays)
                            .toString() +
                        ' Days'
                    : (reservationDetails!.offlineDiscountedDay +
                                reservationDetails!.discountDays)
                            .toString() +
                        ' Days',
                "",
                currentScale),
            buildDetailItem(
                'Discount Amount',
                reservationDetails!.isPaid == true
                    ? '\$' + reservationDetails!.onlineDiscountAmount.toString()
                    : '\$' +
                        reservationDetails!.offlineDiscountAmount.toString(),
                "",
                currentScale),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(currentScale) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Info',
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            buildDetailItem('Full Name', reservationDetails!.driverFullName, "",
                currentScale),
            buildDetailItem(
                'Email', reservationDetails!.email, "", currentScale),
            buildDetailItem(
                'Phone Number', reservationDetails!.phone, "", currentScale),
            buildDetailItem('Number of people including driver',
                reservationDetails!.paxCount, "", currentScale),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfPaymentCard() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16.0),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: reservationDetails!.status == "CANCELLED"
          ? reservationDetails!.isPaid == true
              ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Info',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total pre-paid online:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(reservationDetails!.paymentTotal.toString())
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Refunded amount to your card:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(reservationDetails!.paymentTotal.toString())
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '*It may take up to 5 business days for the amount to be posted to your bank account',
                    ),
                  ],
                )
              : pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                      pw.Text(
                          "Payment info not available due to cancelled reservation")
                    ])
          : reservationDetails!.isPaid == true
              ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Info',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Payment Status:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          "Paid",
                        )
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          reservationDetails!.paymentTotal,
                        )
                      ],
                    ),
                  ],
                )
              : pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Info',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildPdfDetailItem(
                        'Balance to be paid at check in',
                        reservationDetails!.paidAtCheckIn,
                        reservationDetails!.phone.toString()),
                    reservationDetails!.saving != "0"
                        ? _buildPdfDetailItem(
                            'Pre-Pay Online Now',
                            'Pay Now: ${reservationDetails!.onlinePayNow} (SAVE ${double.parse(reservationDetails!.saving).toStringAsFixed(2)})',
                            reservationDetails!.phone.toString())
                        : _buildPdfDetailItem(
                            'Pre-Pay Online Now',
                            'Pay Now: ${reservationDetails!.onlinePayNow}',
                            reservationDetails!.phone.toString()),
                  ],
                ),
    );
  }

  Widget _buildPaymentCard(currentScale) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: reservationDetails!.status == "CANCELLED"
            ? reservationDetails!.isPaid == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Info',
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total pre-paid online:',
                            textScaler: TextScaler.linear(
                                getTextScale(currentScale, 1.25)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(reservationDetails!.paymentTotal.toString())
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Refunded amount to your card:',
                            textScaler: TextScaler.linear(
                                getTextScale(currentScale, 1.25)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(reservationDetails!.paymentTotal.toString())
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '*It may take up to 5 business days for the amount to be posted to your bank account',
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.25)),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                            "Payment info not available due to cancelled reservation")
                      ])
            : reservationDetails!.isPaid == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Info',
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Status:',
                            textScaler: TextScaler.linear(
                                getTextScale(currentScale, 1.25)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {},
                              child: Text(
                                "Paid",
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            textScaler: TextScaler.linear(
                                getTextScale(currentScale, 1.25)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            reservationDetails!.paymentTotal,
                          )
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Info',
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildDetailItem('Balance to be paid at check in',
                          reservationDetails!.paidAtCheckIn, "", currentScale),
                      reservationDetails!.status == "NEW"
                          ? buildOnlinePayButton(currentScale)
                          : Container()
                    ],
                  ),
      ),
    );
  }

  Widget buildOnlinePayButton(currentScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Pre-Pay Online",
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.25)),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 25,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(5),
              textStyle: const TextStyle(fontSize: 12, color: Colors.white),
              backgroundColor: Colors.green, // Set background color to red
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Remove border radius
              ),
            ),
            onPressed: _redirectPrePay,
            child: reservationDetails!.saving != "0"
                ? Text(
                    'Pay Now: ${reservationDetails!.onlinePayNow} (SAVE ${reservationDetails!.saving})',
                    textScaler:
                        TextScaler.linear(getTextScale(currentScale, 1.20)),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  )
                : Text(
                    'Pay Now: ${reservationDetails!.onlinePayNow}',
                    textScaler:
                        TextScaler.linear(getTextScale(currentScale, 1.20)),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(currentScale) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle info',
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            buildDetailItem('Make & Model', reservationDetails!.makeModel, "",
                currentScale),
            buildDetailItem(
                'License Plate', reservationDetails!.plate, "", currentScale),
            buildDetailItem(
                'Length',
                reservationDetails!.vehicleLength == "STANDARD"
                    ? "Under 17ft."
                    : reservationDetails!.vehicleLength == "LARGE"
                        ? "17-19ft."
                        : "19-21ft.",
                "",
                currentScale),
          ],
        ),
      ),
    );
  }

  Widget buildDetailItem(
      String title, String value, String phone, currentScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              title,
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.25)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10), // Add some space between title and value
          Expanded(
            child: value == "CANCELLED"
                ? Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 110,
                      height: 34,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {},
                        child: Text(
                          value,
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.25)),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      // Get.to(
                      //     () => PickupRequestFormPage(
                      //           claimId: int.parse(value),
                      //           phone: phone,
                      //         ),
                      //     transition: Transition.rightToLeft);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        value,
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.25)),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailItemUnderlined(
      String title, String value, String phone, currentScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: Text(
              title,
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.25)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10), // Add some space between title and value
          Expanded(
              child: value == "CANCELLED"
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 110,
                        height: 34,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {},
                          child: Text(
                            value,
                            textScaler: TextScaler.linear(
                                getTextScale(currentScale, 1.25)),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Get.to(
                            () => PickupRequestFormPage(
                                  claimId: int.parse(value),
                                  phone: phone,
                                ),
                            transition: Transition.rightToLeft);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          value,
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.25)),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    )),
        ],
      ),
    );
  }
}
