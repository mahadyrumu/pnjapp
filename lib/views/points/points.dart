import 'package:flutter/material.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/services/point_service.dart';
import 'package:parknjet_app/models/point/point_data_model.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:parknjet_app/views/points/statements/point_statement.dart';
import 'package:get/get.dart';

class Points extends StatefulWidget {
  const Points({super.key});

  @override
  State<Points> createState() => _PointsState();
}

class _PointsState extends State<Points> {
  PointDataModel? pointData;
  bool isLoading = false; // Track loading state
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPoints();
  }

  Future<void> fetchPoints() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      var fetchedPoints = await PointService.fetchPoints();

      setState(() {
        pointData = fetchedPoints;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching points: $e';
      });
      print('Error fetching points: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper function to get the last newBalance
  num? getLastBalance(List<Transaction>? transactions) {
    if (transactions != null && transactions.isNotEmpty) {
      return transactions.first.newBalance;
    }
    return 0; // Return 0.0 if no balance is available
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !isLoading,
          leading: IconButton(
              onPressed: () {
                Get.to(() => const HomePage(),
                    transition: Transition.leftToRight);
              },
              icon: Icon(Icons.arrow_back_ios)),
          actions: [
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.45),
              child: Text(
                'Points',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(
                    fontFamily: 'SP PRO DISPLAy',
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
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
              : pointData == null
                  ? const Center(child: CircularProgressIndicator())
                  : SafeArea(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                        left: 30, right: 30, top: 10),
                                    width: MediaQuery.of(context).size.width,
                                    // color: Colors.blue,
                                    child: Text(
                                      "Lot-1 Days and Points",
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.65)),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 17.5, top: 15, bottom: 0),
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/Icons/coins.png',
                                            ),
                                            width: 50,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 0, left: 5),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.090,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        getLastBalance(pointData
                                                                ?.data
                                                                ?.lot1Reward)
                                                            .toString(),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 25),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text(
                                                      "Earned Points",
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.40)),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: GestureDetector(
                                                      onTap: () => {
                                                        Get.to(
                                                            () => PointStatement(
                                                                toTitle:
                                                                    "Lot 1 Points",
                                                                title:
                                                                    "Park N Jet Lot 1 Points Transactions",
                                                                transactions:
                                                                    pointData
                                                                            ?.data
                                                                            ?.lot1Reward ??
                                                                        []),
                                                            transition: Transition
                                                                .rightToLeft),
                                                      },
                                                      child: Text(
                                                        "Statement",
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.40)),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: const Icon(
                                                      Icons.arrow_forward,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 17.5, top: 15, bottom: 0),
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/Icons/calendar-star.png',
                                            ),
                                            width: 50,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 0, left: 5),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.090,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        getLastBalance(pointData
                                                                ?.data
                                                                ?.lot1Wallet)
                                                            .toString(),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 25),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text(
                                                      "Earned Days",
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.40)),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: GestureDetector(
                                                      onTap: () => {
                                                        Get.to(
                                                            () => PointStatement(
                                                                toTitle:
                                                                    "Lot 1 Days",
                                                                title:
                                                                    "Park N Jet Lot 1 Days Transactions",
                                                                transactions:
                                                                    pointData
                                                                            ?.data
                                                                            ?.lot1Wallet ??
                                                                        []),
                                                            transition: Transition
                                                                .rightToLeft),
                                                      },
                                                      child: Text(
                                                        "Statement",
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.40)),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: const Icon(
                                                      Icons.arrow_forward,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 17.5, top: 15, bottom: 0),
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/Icons/calendar-up.png',
                                            ),
                                            width: 50,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 0, left: 5),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.090,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        getLastBalance(pointData
                                                                ?.data
                                                                ?.lot1Prepaid)
                                                            .toString(),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 25),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text(
                                                      "Prepaid Days",
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.40)),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: GestureDetector(
                                                      onTap: () => {
                                                        Get.to(
                                                            () => PointStatement(
                                                                toTitle:
                                                                    "Lot 1 Prepaid Days",
                                                                title:
                                                                    "Park N Jet Lot 1 Prepaid Days Transactions",
                                                                transactions:
                                                                    pointData
                                                                            ?.data
                                                                            ?.lot1Prepaid ??
                                                                        []),
                                                            transition: Transition
                                                                .rightToLeft),
                                                      },
                                                      child: Text(
                                                        "Statement",
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.40)),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: const Icon(
                                                      Icons.arrow_forward,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      "Lot-2 Days and Points",
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.65)),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 17.5, top: 15, bottom: 0),
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/Icons/coins.png',
                                            ),
                                            width: 50,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 0, left: 5),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.090,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        getLastBalance(pointData
                                                                ?.data
                                                                ?.lot2Reward)
                                                            .toString(),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 25),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text(
                                                      "Earned Points",
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.40)),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: GestureDetector(
                                                      onTap: () => {
                                                        Get.to(
                                                            () => PointStatement(
                                                                toTitle:
                                                                    "Lot 2 Points",
                                                                title:
                                                                    "Park N Jet Lot 2 Points Transactions",
                                                                transactions:
                                                                    pointData
                                                                            ?.data
                                                                            ?.lot2Reward ??
                                                                        []),
                                                            transition: Transition
                                                                .rightToLeft),
                                                      },
                                                      child: Text(
                                                        "Statement",
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.40)),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: const Icon(
                                                      Icons.arrow_forward,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 17.5, top: 15, bottom: 0),
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/Icons/calendar-star.png',
                                            ),
                                            width: 50,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 0, left: 5),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.090,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        getLastBalance(pointData
                                                                ?.data
                                                                ?.lot2Wallet)
                                                            .toString(),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 25),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text(
                                                      "Earned Days",
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.40)),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: GestureDetector(
                                                      onTap: () => {
                                                        Get.to(
                                                            () => PointStatement(
                                                                toTitle:
                                                                    "Lot 2 Days",
                                                                title:
                                                                    "Park N Jet Lot 2 Days Transactions",
                                                                transactions:
                                                                    pointData
                                                                            ?.data
                                                                            ?.lot2Wallet ??
                                                                        []),
                                                            transition: Transition
                                                                .rightToLeft),
                                                      },
                                                      child: Text(
                                                        "Statement",
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.40)),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: const Icon(
                                                      Icons.arrow_forward,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 17.5, top: 15, bottom: 0),
                                          alignment: Alignment.centerLeft,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/Icons/calendar-up.png',
                                            ),
                                            width: 50,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 0, left: 5),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.090,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0),
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 8),
                                                      child: Text(
                                                        getLastBalance(pointData
                                                                ?.data
                                                                ?.lot2Prepaid)
                                                            .toString(),
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 25),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text(
                                                      "Prepaid Days",
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.40)),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: GestureDetector(
                                                      onTap: () => {
                                                        Get.to(
                                                            () => PointStatement(
                                                                toTitle:
                                                                    "Lot 2 Prepaid Days",
                                                                title:
                                                                    "Park N Jet Lot 2 Prepaid Days Transactions",
                                                                transactions:
                                                                    pointData
                                                                            ?.data
                                                                            ?.lot2Prepaid ??
                                                                        []),
                                                            transition: Transition
                                                                .rightToLeft),
                                                      },
                                                      child: Text(
                                                        "Statement",
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.40)),
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: const Icon(
                                                      Icons.arrow_forward,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ));
  }
}
