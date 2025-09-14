import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/vehicle_controller.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:parknjet_app/views/popup_vehicle.dart';
import 'package:parknjet_app/views/vehicle/add_vehicle.dart';

class Vehicles extends StatefulWidget {
  const Vehicles({super.key});

  @override
  State<Vehicles> createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  final VehicleController vehicleController = Get.put(VehicleController());

  Future<void> _handleRefresh() async {
    await vehicleController.refreshVehicles();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Obx(() {
            // Use Obx to rebuild AppBar based on loading state
            return AppBar(
              leading: vehicleController.loading.value
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.to(() => const HomePage(),
                            transition: Transition.leftToRight);
                      },
                    ),
              title: Text(
                'Vehicles',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(
                  fontFamily: 'SP PRO DISPLAY',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: !vehicleController.loading.value,
            );
          }),
        ),
        body: Obx(() {
          return vehicleController.loading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      vehicleController.loading.value
                          ? const SizedBox.shrink()
                          : Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: screenWidth * 0.7,
                                child: ElevatedButton(
                                  onPressed: () {
                                    vehicleController.makeModelController
                                        .clear();
                                    vehicleController.plateController.clear();
                                    vehicleController.setPlateErrorMessage('');

                                    Get.to(() => AddVehicleForm(),
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
                                  child: Row(children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Image(
                                        image:
                                            AssetImage('assets/Icons/plus.png'),
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        'Add New Vehicle',
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.65)),
                                        style: const TextStyle(
                                          fontFamily: 'SF PRO DISPLAY',
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                      const Gap(10),
                      Expanded(
                        child: vehicleController.vehicleList.isEmpty
                            ? Center(
                                child: FittedBox(
                                  child: Text(
                                    'No vehicles are added',
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
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _handleRefresh,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      vehicleController.vehicleList.length,
                                  itemBuilder: (context, index) {
                                    final singleVehicle =
                                        vehicleController.vehicleList[index];
                                    return Column(
                                      children: [
                                        SingleChildScrollView(
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300]),
                                            child: Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image(
                                                  image: singleVehicle
                                                              .vehicleLength ==
                                                          "LARGE"
                                                      ? AssetImage(
                                                          'assets/images/Car_l.png')
                                                      : singleVehicle
                                                                  .vehicleLength ==
                                                              "STANDARD"
                                                          ? AssetImage(
                                                              'assets/images/Car.png')
                                                          : AssetImage(
                                                              'assets/images/Car_xl.png'),
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.60,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 25),
                                                      child: Text(
                                                        maxLines: 2,
                                                        singleVehicle.makeModel,
                                                        textScaler:
                                                            TextScaler.linear(
                                                                getTextScale(
                                                                    currentScale,
                                                                    1.65)),
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'SF PRO DISPLAY',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 25),
                                                    child: PopupMenuVehicle(
                                                        id: singleVehicle.id,
                                                        makeModel: singleVehicle
                                                            .makeModel,
                                                        plate:
                                                            singleVehicle.plate,
                                                        vehicleLength:
                                                            singleVehicle
                                                                .vehicleLength,
                                                        currentScale:
                                                            currentScale),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                margin: const EdgeInsets.only(
                                                    left: 25, top: 5),
                                                child: Text(
                                                  singleVehicle.vehicleLength ==
                                                          "LARGE"
                                                      ? "17-19ft."
                                                      : singleVehicle
                                                                  .vehicleLength ==
                                                              "STANDARD"
                                                          ? "Under 17ft."
                                                          : "19-21ft.",
                                                  textScaler: TextScaler.linear(
                                                      getTextScale(
                                                          currentScale, 1.65)),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                margin: const EdgeInsets.only(
                                                    top: 5,
                                                    left: 25,
                                                    bottom: 20),
                                                child: Text(
                                                  singleVehicle.plate,
                                                  textScaler: TextScaler.linear(
                                                      getTextScale(
                                                          currentScale, 1.65)),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                        const Gap(16),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                );
        }));
  }
}
