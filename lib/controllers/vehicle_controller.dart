import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:parknjet_app/models/vehicle/vehicles.dart';
import 'package:parknjet_app/services/vehicle_service.dart';
import 'package:parknjet_app/views/vehicle/vehicles.dart';

class VehicleController extends GetxController {
  var vehicleList = <VehicleDataModel>[].obs;
  var loading = true.obs;
  var isInitialLoad = true;
  var selectedVehicleLength = ''.obs;
  RxString plateErrorMessage = ''.obs;

  TextEditingController makeModelController = TextEditingController();
  TextEditingController plateController = TextEditingController();

  void setPlateErrorMessage(String value) {
    plateErrorMessage.value = value; // Set the string value
  }

  void resetPlateErrorMessage() {
    plateErrorMessage.value = ''; // Reset the string value
  }

  Future<void> getVehicle() async {
    if (isInitialLoad) {
      loading.value = true;
      try {
        var vehicles = await VehicleService.fetchVehicles();
        vehicles.sort((a, b) => b.id.compareTo(a.id));
        vehicleList.assignAll(vehicles);
      } catch (e) {
        Get.snackbar(
          "Error fetching vehicles",
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

  addVehicle(BuildContext context) async {
    String makeModel = makeModelController.text;
    String plate = plateController.text;
    String length = selectedVehicleLength.value;

    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final response =
          await VehicleService.addVehicle(makeModel, plate, length);
      if (response.success) {
        VehicleDataModel newVehicle = VehicleDataModel.fromJson(response.data);
        Navigator.of(context).pop();

        if (newVehicle.id != 0) {
          // Update vehicle list and show success message
          vehicleList.insert(0, newVehicle); // Insert at the beginning
          Get.snackbar(
            "Done",
            "New Vehicle added.",
            colorText: Colors.green,
            backgroundColor: Colors.green[50],
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.to(() => const Vehicles(), transition: Transition.rightToLeft);
        } else {
          Get.snackbar(
            "Error",
            "Failed to retrieve the vehicle ID.",
            colorText: Colors.red,
            backgroundColor: Colors.red[50],
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        plateErrorMessage.value = response.message;
        Navigator.of(context).pop();
      }
    } catch (e) {
      Get.snackbar(
        "Error adding Vehicle",
        "$e",
        colorText: Colors.red,
        backgroundColor: Colors.red[50],
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.of(context).pop();
    } finally {
      loading.value = false;
    }
  }

  updateVehicle(BuildContext context, int id) async {
    String makeModel = makeModelController.text;
    String plate = plateController.text;
    String length = selectedVehicleLength.value;

    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final response =
          await VehicleService.updateVehicle(id, makeModel, plate, length);
      if (response.success) {
        Navigator.of(context).pop();

        // Find the index of the updated vehicle in the list and update it
        int index = vehicleList.indexWhere((vehicle) => vehicle.id == id);
        if (index != -1) {
          vehicleList[index] = VehicleDataModel(
            id: id,
            makeModel: makeModel,
            plate: plate,
            vehicleLength: length,
          );
        }

        Get.snackbar(
          "Done",
          "Vehicle info updated successfully.",
          colorText: Colors.green,
          backgroundColor: Colors.green[50],
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.to(() => const Vehicles(), transition: Transition.rightToLeft);
      } else {
        plateErrorMessage.value = response.message;
        Navigator.of(context).pop();
      }
    } catch (e) {
      Get.snackbar(
        "Error updating Vehicle",
        "$e",
        colorText: Colors.red,
        backgroundColor: Colors.red[50],
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.of(context).pop();
    } finally {
      loading.value = false;
    }
  }

  deleteVehicle(BuildContext context, int id) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      await VehicleService.deleteVehicle(context, id);
      Navigator.of(context).pop();
      vehicleList.removeWhere((vehicle) => vehicle.id == id);
      print('object');
      Get.snackbar(
        "Done",
        "Successfully deleted.",
        colorText: Colors.green,
        backgroundColor: Colors.green[50],
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error deleting vehicle",
        "$e",
        colorText: Colors.red,
        backgroundColor: Colors.red[50],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshVehicles() async {
    await getVehicle();
  }

  void resetState() {
    isInitialLoad = false;
  }

  @override
  void onInit() {
    super.onInit();
    getVehicle();
  }
}
