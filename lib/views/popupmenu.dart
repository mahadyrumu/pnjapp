import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/drivercontroller.dart';
import 'package:parknjet_app/views/driver/update_driver.dart';

class PopupMenu extends StatelessWidget {
  PopupMenu({
    super.key,
    required this.id,
    required this.fullname,
    required this.phone,
    required this.email,
    required this.currentScale,
  });

  final int id;
  final String fullname;
  final String phone;
  final String email;
  final double currentScale;
  final controller = Get.put(
    DriverController(),
  );
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            Navigator.of(context).pop();
            controller.setEmailErrorMessage('');
            Get.to(
                () => UpdateDriverForm(
                    fullname: fullname, phone: phone, email: email, id: id),
                preventDuplicates: false,
                transition: Transition.rightToLeft);
            // editDriverInfo(context, id, fullname, phone, email);
          },
          child: Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Edit',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            controller.deleteDriver(context, id);
          },
          child: Row(
            children: [
              const Icon(Icons.delete),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Remove',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              )
            ],
          ),
        ),
      ],
      offset: const Offset(-20, 20),
      color: Colors.white,
      elevation: 2,
      child: const Icon(Icons.more_vert),
    );
  }
}
