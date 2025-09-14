import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/drivercontroller.dart';
import 'package:parknjet_app/views/driver/add_driver.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:parknjet_app/views/popupmenu.dart';

class Drivers extends StatefulWidget {
  const Drivers({super.key});

  @override
  State<Drivers> createState() => _DriversState();
}

class _DriversState extends State<Drivers> {
  final controller = Get.put(DriverController(), permanent: true);

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    controller.resetState();
    controller.getDriver();
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Obx(() {
          return AppBar(
            leading: controller.loading.value
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Get.to(() => const HomePage(),
                          transition: Transition.leftToRight);
                    },
                  ),
            title: Text(
              'Drivers',
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              style: const TextStyle(
                  fontFamily: 'SP PRO DISPLAy',
                  fontSize: 24,
                  fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
            automaticallyImplyLeading: !controller.loading.value,
          );
        }),
      ),
      body: Obx(() {
        return controller.loading.value && controller.isInitialLoad
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    controller.loading.value
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: screenWidth * 0.6,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.nameController.clear();
                                  controller.emailController.clear();
                                  controller.phoneController.clear();
                                  controller.setEmailErrorMessage('');

                                  Get.to(() => AddDriverForm(),
                                      preventDuplicates: false,
                                      transition: Transition.rightToLeft);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: const Image(
                                        image:
                                            AssetImage('assets/Icons/plus.png'),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        maxLines: 2,
                                        'Add new driver',
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.65)),
                                        style: const TextStyle(
                                          fontFamily: 'SF PRO DISPLAY',
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: controller.driversList.isEmpty
                            ? Center(
                                child: Text(
                                  'No driver added',
                                  textScaler: TextScaler.linear(
                                      getTextScale(currentScale, 1.65)),
                                  style: GoogleFonts.roboto(
                                    textStyle: const TextStyle(
                                      letterSpacing: 2.0,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.driversList.length,
                                itemBuilder: (context, index) {
                                  final singleDriver =
                                      controller.driversList[index];
                                  return Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(width: 1.0)),
                                    ),
                                    child: Column(
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    width: screenWidth * 0.60,
                                                    child: Text(
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                      singleDriver.fullName,
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.65)),
                                                    )),
                                                SizedBox(
                                                    width: screenWidth * 0.60,
                                                    child: Text(
                                                      singleDriver.phone,
                                                      textScaler:
                                                          TextScaler.linear(
                                                              getTextScale(
                                                                  currentScale,
                                                                  1.65)),
                                                    )),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5, bottom: 5),
                                                  child: SizedBox(
                                                      width: screenWidth * 0.60,
                                                      child: Text(
                                                        singleDriver.email,
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                      )),
                                                ),
                                              ],
                                            ),
                                            PopupMenu(
                                              currentScale: currentScale,
                                              id: singleDriver.id,
                                              fullname: singleDriver.fullName,
                                              phone: singleDriver.phone,
                                              email: singleDriver.email,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }
}
