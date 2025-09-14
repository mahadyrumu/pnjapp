import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/drivercontroller.dart';
import 'package:parknjet_app/views/driver/drivers.dart';
import 'package:parknjet_app/views/text_field.dart';

class UpdateDriverForm extends StatelessWidget {
  final String fullname;
  final String phone;
  final String email;
  final int id;
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(DriverController());

  UpdateDriverForm({
    super.key,
    required this.fullname,
    required this.phone,
    required this.email,
    required this.id,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.nameController.text = fullname;
      controller.emailController.text = email;
      controller.phoneController.text = phone;
      controller.emailErrorMessage.value = ''; // Clear error message
    });
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Driver',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const Drivers(), transition: Transition.leftToRight);
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
                  'Update driver details',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CustomTextField(
                  label: 'Name',
                  controller: controller.nameController,
                  hint: "Name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  number: false),
              const SizedBox(height: 15),
              CustomTextField(
                  label: 'Email',
                  controller: controller.emailController,
                  hint: "Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                  number: false),
              Obx(() {
                return controller.emailErrorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          controller.emailErrorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : Container();
              }),
              const SizedBox(height: 15),
              CustomTextField(
                  label: 'Phone Number',
                  controller: controller.phoneController,
                  hint: "Phone Number",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    } else if (!RegExp(r'^\(\d{3}\) \d{3}-\d{4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  number: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.updateDriver(context, id);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Update Details',
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
