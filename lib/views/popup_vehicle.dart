import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/vehicle_controller.dart';
// import 'package:parknjet_app/services/vehicle_service.dart';
import 'package:parknjet_app/views/vehicle/update_vehicle.dart';

class PopupMenuVehicle extends StatelessWidget {
  PopupMenuVehicle({
    super.key,
    required this.id,
    required this.makeModel,
    required this.plate,
    required this.vehicleLength,
    required this.currentScale,
  });

  final int id;
  final String makeModel;
  final String plate;
  final String vehicleLength;
  final double currentScale;

  final controller = Get.put(
    VehicleController(),
  );

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            Navigator.of(context).pop(); // Close the popup menu
            controller.setPlateErrorMessage('');

            Get.to(
                () => UpdateVehicleForm(
                      id: id,
                      makeModel: makeModel,
                      plate: plate,
                      vehicleLength: vehicleLength,
                    ),
                preventDuplicates: false);
          },
          child: Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(width: 10),
              Text(
                'Edit',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            Future.delayed(Duration.zero, () {
              controller.deleteVehicle(context, id);
            });
          },
          child: Row(
            children: [
              const Icon(Icons.delete),
              const SizedBox(width: 10),
              Text(
                'Remove',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              ),
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
