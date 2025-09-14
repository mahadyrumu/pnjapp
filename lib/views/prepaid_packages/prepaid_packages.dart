import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/prepaid_package_controller.dart';
import 'package:parknjet_app/models/prepaid_packages/prepaid_package.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PrepaidPackages extends StatefulWidget {
  const PrepaidPackages({super.key});

  @override
  State<PrepaidPackages> createState() => _PrepaidPackagesState();
}

class _PrepaidPackagesState extends State<PrepaidPackages>
    with WidgetsBindingObserver {
  final PrepaidPackageController prepaidPackageController =
      Get.put(PrepaidPackageController());

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

  Future<void> _launchUrl(lotType, packageId) async {
    var lot = 1;
    if (lotType == "LOT_1") {
      lot = 1;
    } else {
      lot = 2;
    }
    String? token = await GetToken.getToken();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");
    final Uri _url = Uri.parse(
        'https://plg.parknjetseatac.com/redirect-from-app?url=packages/lot-$lot/$packageId&token=$token&id=$userId');

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  String _formatDate(DateTime date) {
    // final DateFormat formatter = DateFormat('MMM d, y hh:mm a');
    final DateFormat formatter = DateFormat('MM/d/y hh:mm a');
    return formatter.format(date);
  }

  Future<void> _handleRefresh() async {
    await prepaidPackageController.fetchPrepaidPackageDays();
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prepaid Packages',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const HomePage(),
                  transition: Transition.leftToRight);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Obx(
        () {
          if (prepaidPackageController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var packages = prepaidPackageController.packages;
          var lot1Packages =
              packages.where((p) => p.lotType == 'LOT_1').toList();
          var lot2Packages =
              packages.where((p) => p.lotType == 'LOT_2').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Park N Jet Prepaid Packages',
                    textScaler:
                        TextScaler.linear(getTextScale(currentScale, 1.65)),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    'No Blackout Dates with reservations',
                    textScaler:
                        TextScaler.linear(getTextScale(currentScale, 1.65)),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                prepaidPackageController.lot1PrepaidDays.value.toString() ==
                            "0.0" &&
                        prepaidPackageController.lot2PrepaidDays.value
                                .toString() ==
                            "0.0"
                    ? Column(
                        children: [
                          const Gap(8),
                          Center(
                            child: Text(
                              'Your Available Packages',
                              textScaler: TextScaler.linear(
                                  getTextScale(currentScale, 1.65)),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Table(
                                columnWidths: const {
                                  0: FractionColumnWidth(.20),
                                  1: FractionColumnWidth(.35),
                                  2: FractionColumnWidth(.45),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Colors.orange[300]),
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Lot",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text("Available Days",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text("Expiry Date",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                      decoration: BoxDecoration(
                                          color: Colors.orange[50]),
                                      children: [
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Lot 1",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text("0"),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text("--"),
                                            ),
                                          ),
                                        ),
                                      ]),
                                  TableRow(
                                      decoration: BoxDecoration(
                                          color: Colors.orange[50]),
                                      children: [
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Lot 2",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text("0"),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text("--"),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const Gap(8),
                          Center(
                            child: Text(
                              'Your Available Packages',
                              textScaler: TextScaler.linear(
                                  getTextScale(currentScale, 1.65)),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Table(
                                columnWidths: const {
                                  0: FractionColumnWidth(.20),
                                  1: FractionColumnWidth(.35),
                                  2: FractionColumnWidth(.45),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Colors.orange[300]),
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Lot",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text("Available Days",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text("Expiry Date",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                      decoration: BoxDecoration(
                                          color: Colors.orange[50]),
                                      children: [
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Lot 1",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                prepaidPackageController
                                                    .lot1PrepaidDays.value
                                                    .toString(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                _formatDate(DateTime.parse(
                                                    prepaidPackageController
                                                        .lot1ExpirationDate
                                                        .value)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                  TableRow(
                                      decoration: BoxDecoration(
                                          color: Colors.orange[50]),
                                      children: [
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Lot 2",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                prepaidPackageController
                                                    .lot2PrepaidDays.value
                                                    .toString(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                _formatDate(DateTime.parse(
                                                    prepaidPackageController
                                                        .lot2ExpirationDate
                                                        .value)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                const Gap(10),
                Center(
                  child: Text(
                    'Buy prepaid packages and save!',
                    textScaler:
                        TextScaler.linear(getTextScale(currentScale, 1.65)),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Gap(10),
                Text(
                  'Lot 1',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  'These packages can only be used for Lot 1 reservations. Partially used prepaid packages are not refundable.',
                  style: const TextStyle(fontSize: 15),
                ),
                const Gap(8),
                ...lot1Packages.asMap().entries.map((pkg) =>
                    buildPackageCard(pkg.value, pkg.key, currentScale)),
                const SizedBox(height: 16.0),
                Text(
                  'Lot 2',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'These packages can only be used for Lot 2 reservations. Partially used prepaid packages are not refundable.',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 8.0),
                ...lot2Packages.asMap().entries.map((pkg) =>
                    buildPackageCard(pkg.value, pkg.key, currentScale)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPackageCard(PrepaidPackage package, index, currentScale) {
    String? userType = null;
    if (index == 0) {
      userType = "Rare Users";
    } else if (index == 1) {
      userType = "Regular Users";
    } else if (index == 2) {
      userType = "Frequent Users";
    }

    var pricePreDecimal = '00';
    var pricePostDecimal = '00';
    // Format the price to show decimal part as a degree symbol
    var priceParts = package.price.split('.');
    if (priceParts.length == 2) {
      pricePreDecimal = priceParts[0];
      pricePostDecimal = priceParts[1];
    } else {
      pricePreDecimal = priceParts[0];
      pricePostDecimal = '00';
    }

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$$pricePreDecimal',
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ".",
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pricePostDecimal,
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.superscripts()]),
                      ),
                      Text(
                        ' / ${package.days} Days',
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 1.0,
                    color: Colors.grey[350],
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${package.days} days of parking',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(fontSize: 15.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${package.expirationDurationInMonths} months to redeem',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(fontSize: 15.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '\$${package.savings}.00 Saving',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(fontSize: 15.0),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Best for ${userType}',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(fontSize: 15.0),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(
                        255, 240, 182, 36), // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5.0), // Very low radius
                    ),
                  ),
                  onPressed: () {
                    _launchUrl(package.lotType, package.id.toString());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Buy Now!',
                        textScaler:
                            TextScaler.linear(getTextScale(currentScale, 1.65)),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
