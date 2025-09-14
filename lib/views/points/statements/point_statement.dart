import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/models/point/point_data_model.dart';

class PointStatement extends StatefulWidget {
  final List<Transaction> transactions;
  final String toTitle;
  final String title;

  const PointStatement(
      {super.key,
      required this.title,
      required this.toTitle,
      required this.transactions});

  @override
  State<PointStatement> createState() => _PointStatementState();
}

class _PointStatementState extends State<PointStatement> {
  @override
  void initState() {
    super.initState();
  }

  Map<String, String> triggerTypeArray = {
    "PREPAID_PACKAGE": "Prepaid package purchase",
    "RESERVATION_CANCELLATION": "Reservation cancelled",
    "REFERRAL": "Invitation of a friend",
    "RESERVATION_PAID": "Reservation paid",
    "MAX_POINTS_REACHED": "Points Conversion To Days",
    "RESERVATION_CHECKED_OUT": "Completed a reservation",
    "EARLY_PICKUP": "Early Pickup",
    "COMPLIMENTARY": "Customer Satisfaction",
    "REFUND": "Transaction Refund",
    "SIGNUP_COUPON": "Sign up coupon code",
    "MISCELLENIOUS": "Other"
  };

  DateTime convertToDateTime(String dateTimeString) {
    return DateTime.parse(dateTimeString).toLocal();
  }

  String formatBalance(num balance) {
    return balance.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.toTitle,
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.30)),
          style: const TextStyle(
              fontFamily: 'SP PRO DISPLAy',
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: <Widget>[
              Text(
                widget.title.toString(),
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              widget.transactions.isEmpty
                  ? Material(
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey[300],
                        width: double.infinity,
                        child: Text(
                          "No translations yet!",
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Material(
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey[300],
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildHeader('Date', currentScale),
                            ),
                            Expanded(
                              child: _buildHeader('Old Days', currentScale),
                            ),
                            Expanded(
                              child: _buildHeader('New Days', currentScale),
                            ),
                            Expanded(
                              child: _buildHeader('Note', currentScale),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              ...widget.transactions.map((transection) {
                var h = 0;
                return Card(
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Remove border radius
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildText(
                              DateFormat('yyyy-MM-dd hh:mm a').format(
                                  convertToDateTime(
                                      transection.createdDate.toString())),
                              false,
                              currentScale),
                        ),
                        Expanded(
                          child: _buildText(transection.oldBalance!.toString(),
                              true, currentScale),
                        ),
                        Expanded(
                          child: _buildText(transection.newBalance!.toString(),
                              true, currentScale),
                        ),
                        Expanded(
                          child: _buildText(
                              triggerTypeArray[transection.triggerType]
                                  .toString(),
                              false,
                              currentScale),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text, currentScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        text,
        textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildText(String text, bool alignRight, currentScale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        style: const TextStyle(fontSize: 12),
        text,
        textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}
