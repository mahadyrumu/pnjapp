import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/vehicle_controller.dart';
import 'package:parknjet_app/views/text_field.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:parknjet_app/views/vehicle/vehicles.dart';

class UpdateVehicleForm extends StatelessWidget {
  final String makeModel;
  final String plate;
  final String vehicleLength;
  final int id;

  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(VehicleController());
  final List<String> items = ['STANDARD', 'LARGE', 'EXTRA_LARGE'];
  final Map<String, String> vehicleLengthDescriptions = {
    'STANDARD': 'Under 17ft.',
    'LARGE': '17-19ft.',
    'EXTRA_LARGE': '19-21ft.',
  };

  UpdateVehicleForm({
    super.key,
    required this.makeModel,
    required this.plate,
    required this.vehicleLength,
    required this.id,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.makeModelController.text = makeModel;
      controller.plateController.text = plate;
      controller.selectedVehicleLength.value = vehicleLength;
    });
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Vehicle',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const Vehicles(),
                  transition: Transition.leftToRight);
            },
            icon: Icon(Icons.arrow_back_ios)),
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
                  'Update Vehicle details',
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
                'Vehicle Length',
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
                  hint: Obx(() {
                    final length = controller.selectedVehicleLength.value;
                    final description = vehicleLengthDescriptions[length];
                    return Text(
                      description ?? 'Select Vehicle Length',
                      style: const TextStyle(fontSize: 14),
                    );
                  }),
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              vehicleLengthDescriptions[item]!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                      .toList(),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.updateVehicle(context, id);
                  }
                },
                child: const Text(
                  'Update Vehicle',
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
