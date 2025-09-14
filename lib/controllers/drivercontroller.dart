import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/models/driver/driver.dart';
import 'package:parknjet_app/services/driver_service.dart';
import 'package:parknjet_app/views/driver/drivers.dart';

class DriverController extends GetxController {
  List<DriverDataModel> driversList = <DriverDataModel>[].obs;
  var loading = true.obs;
  var isInitialLoad = true;
  RxString emailErrorMessage = ''.obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  void setEmailErrorMessage(String value) {
    emailErrorMessage.value = value; // Set the string value
  }

  void resetEmailErrorMessage() {
    emailErrorMessage.value = ''; // Reset the string value
  }

  Future<void> getDriver() async {
    if (isInitialLoad) {
      loading.value = true;
      try {
        var drivers = await DriverService.fetchDrivers();
        driversList.assignAll(drivers);
      } catch (e) {
        Get.snackbar(
          "Error fetching drivers",
          "$e",
          colorText: Colors.red,
          backgroundColor: Colors.red[50],
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        loading.value = false;
        isInitialLoad = false;
      }
    }
  }

  Future<void> addDriver(BuildContext context) async {
    String fullName = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;

    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      var newDriver = await DriverService.addDriver(fullName, email, phone);
      Navigator.of(context).pop();

      // Update UI
      driversList.insert(0, newDriver);
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      Get.snackbar(
        "Done",
        "New driver added.",
        colorText: Colors.green,
        backgroundColor: Colors.green[50],
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.of(context).pop();
    } catch (e) {
      // Get.snackbar(
      //   "Error adding driver",
      //   "$e",
      //   colorText: Colors.red,
      //   backgroundColor: Colors.red[50],
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      Navigator.of(context).pop();
    } finally {
      loading.value = false;
      isInitialLoad = false;
    }
  }

  Future<void> updateDriver(BuildContext context, int id) async {
    String updatedName = nameController.text;
    String updatedEmail = emailController.text;
    String updatedPhone = phoneController.text;

    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await DriverService.updateDriver(
          id, updatedName, updatedEmail, updatedPhone);
      Navigator.of(context).pop();

      int index = driversList.indexWhere((driver) => driver.id == id);

      if (index != -1) {
        driversList[index] = DriverDataModel(
          id: id,
          fullName: updatedName,
          email: updatedEmail,
          phone: updatedPhone,
        );
      }

      Get.snackbar(
        "Done",
        "Driver info updated successfully.",
        colorText: Colors.green,
        backgroundColor: Colors.green[50],
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.of(context).pop();
      Get.to(() => const Drivers(), transition: Transition.rightToLeft);
    } catch (e) {
      // Get.snackbar(
      //   "Error updating driver",
      //   "$e",
      //   colorText: Colors.red,
      //   backgroundColor: Colors.red[50],
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      Navigator.of(context).pop();
    }
  }

  Future<void> deleteDriver(BuildContext context, int id) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await DriverService.deleteDriver(context, id);
      Navigator.of(context).pop();

      int index = driversList.indexWhere((driver) => driver.id == id);
      if (index != -1) {
        driversList.removeAt(index);
      }

      Get.snackbar(
        "Done",
        "Successfully deleted.",
        colorText: Colors.green,
        backgroundColor: Colors.green[50],
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error deleting driver",
        "$e",
        colorText: Colors.red,
        backgroundColor: Colors.red[50],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void resetState() {
    isInitialLoad = false;
  }

  @override
  void onInit() {
    super.onInit();
    getDriver();
  }
}
