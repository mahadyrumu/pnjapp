import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/vehicle_controller.dart';
import 'package:parknjet_app/views/text_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AddVehicleForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  AddVehicleForm({super.key});
  final controller = Get.put(VehicleController());
  final List<String> items = ['STANDARD', 'LARGE', 'EXTRA_LARGE'];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Vehicle',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Enter Vehicle details',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CustomTextField(
                  label: 'Vehicle Identification Name',
                  controller: controller.makeModelController,
                  hint: 'Vehicle Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vehicle name';
                    }
                    return null;
                  },
                  number: false),
              const SizedBox(height: 15),
              CustomTextField(
                  label: 'License Plate',
                  controller: controller.plateController,
                  hint: 'Plate Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter plate number';
                    }
                    return null;
                  },
                  number: false),
              Obx(() {
                return controller.plateErrorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          controller.plateErrorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : Container();
              }),
              const SizedBox(height: 15),
              const Text(
                "Vehicle Length",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonFormField2(
                  decoration: InputDecoration(
                    // labelText: 'Vehicle Length',
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  isExpanded: true,
                  hint: const Text(
                    'Select Vehicle Length',
                    style: TextStyle(fontSize: 14),
                  ),
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item == "STANDARD"
                                  ? "Under 17ft."
                                  : item == "LARGE"
                                      ? "17-19ft."
                                      : "19-21ft.",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                      .toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a vehicle length';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    controller.selectedVehicleLength.value = value as String;
                  },
                  onSaved: (value) {
                    controller.selectedVehicleLength.value = value as String;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.addVehicle(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Save Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
