import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/models/reservations/reservations.dart';
import 'package:parknjet_app/services/request_pickup_service.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:parknjet_app/views/request_pickup/instructions.dart';
import 'package:parknjet_app/controllers/reservation_controller.dart';

class PickupRequestFormPage extends StatefulWidget {
  final int claimId;
  final String phone;
  const PickupRequestFormPage(
      {super.key, required this.claimId, required this.phone});

  @override
  State<PickupRequestFormPage> createState() => _PickupRequestFormPageState();
}

class _PickupRequestFormPageState extends State<PickupRequestFormPage> {
  final ReservationController reservationController = Get.find();
  TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int? _claimId;
  String? _phoneNumber;
  int? _minutes;
  String? _island = "1A";
  List<bool> _isSelected = [true, false];
  String message = "";
  bool _isSubmitting = false; // Add a flag to indicate form submission status

  // Mask Formatter for US Phone Number (e.g., (123) 456-7890)
  final maskFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {'#': RegExp(r'[0-9]')}, // Only allow digits
    type: MaskAutoCompletionType.lazy,
  );

  // Reset the formatter when needed
  void resetFormatter() {
    maskFormatter.clear();
  }

  void _handleIslandSelection(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }
      _island = index == 0 ? '1A' : '3A';
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true; // Show the loader
        message = "";
      });
      try {
        final response = await RequestPickupService.createRequestPickup(
          _claimId!,
          _phoneNumber ?? '',
          _minutes!,
          _island!,
        );
        if (response.success) {
          Get.snackbar(
            "Done",
            "Pickup request placed successfully!",
            colorText: Colors.green,
            backgroundColor: Colors.white,
          );
          Get.to(() => const Instructions(), // Navigate to InstructionsPage
              transition: Transition.rightToLeft);
        } else {
          setState(() {
            message = response.message;
          });
        }
      } catch (e) {
        setState(() {
          message = "Failed to request pickup";
        });
      } finally {
        setState(() {
          _isSubmitting = false; // Hide the loader
        });
      }
    }
  }

  void _updatePhoneNumber(claimId) {
    ReservationDataModel? selectedReservation =
        reservationController.reservations.firstWhere(
      (reservation) => reservation.claimId == claimId,
    );

    if (selectedReservation != null) {
      print('Phone number: ${selectedReservation.phone}');
      _phoneNumber = selectedReservation.phone;
      _phoneController.text = _phoneNumber!;
    } else {
      _phoneNumber = "";
      _phoneController.text = ""!;
    }
  }

  @override
  void initState() {
    super.initState();
    _minutes = 9;
    if (widget.claimId != 0) {
      _claimId = widget.claimId.toInt();
      _phoneNumber = widget.phone.toString();
      _phoneController.text = widget.phone.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Pickup',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const HomePage(),
                  transition: Transition.leftToRight);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Obx(() {
        if (reservationController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else {
          List<int> claimIds = reservationController.reservations
              .where((reservation) =>
                  reservation.claimId != 0 &&
                  (reservation.status == 'NEW' ||
                      reservation.status == 'CHECKED_IN'))
              .map((reservation) => reservation.claimId)
              .toList();
          if (claimIds.isNotEmpty && _claimId == null) {
            _claimId = claimIds.first; // Auto-select the first Claim ID
            _updatePhoneNumber(_claimId);
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    claimIds.isNotEmpty
                        ? DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Claim ID',
                              labelStyle: TextStyle(
                                fontSize:
                                    getHintTextScale(currentScale, 0.80, 16),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            value: _claimId,
                            items: claimIds
                                .map((claimId) => DropdownMenuItem<int>(
                                      value: claimId,
                                      child: Text(
                                        claimId.toString(),
                                        style: TextStyle(
                                          fontSize: getHintTextScale(
                                              currentScale, 0.75, 16),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a Claim ID';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _claimId = value;
                                _updatePhoneNumber(
                                    _claimId); // Update phone number based on selected Claim ID
                              });
                            },
                          )
                        : TextFormField(
                            style: TextStyle(
                              fontSize:
                                  getHintTextScale(currentScale, 0.75, 16),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Claim ID',
                              labelStyle: TextStyle(
                                fontSize:
                                    getHintTextScale(currentScale, 0.80, 16),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a Claim ID';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _claimId = int.tryParse(value!);
                              // _updatePhoneNumber(
                              //     _claimId); // Update phone number based on entered Claim ID
                            },
                          ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: TextStyle(
                        fontSize: getHintTextScale(currentScale, 0.75, 16),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        labelStyle: TextStyle(
                          fontSize: getHintTextScale(currentScale, 0.80, 16),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      inputFormatters: [maskFormatter],
                      keyboardType: TextInputType.phone,
                      onSaved: (value) {
                        _phoneNumber = value;
                      },
                      controller: _phoneController,
                    ),
                    currentScale > 1.0 ? const Gap(32) : const Gap(16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        label: const Text(
                            'Minutes (You will be there at the island)'),
                        labelStyle: TextStyle(
                          fontSize: getHintTextScale(currentScale, 0.80, 16),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      value: _minutes,
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            '--',
                            style: TextStyle(
                              fontSize:
                                  getHintTextScale(currentScale, 0.75, 16),
                            ),
                          ),
                        ),
                        ...List.generate(10, (index) => index + 1)
                            .map((minute) => DropdownMenuItem<int>(
                                  value: minute,
                                  child: Text(
                                    minute.toString(),
                                    style: TextStyle(
                                      fontSize: getHintTextScale(
                                          currentScale, 0.75, 16),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _minutes = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select minutes';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Island (You are waiting at)',
                      style: TextStyle(
                          fontSize: getHintTextScale(currentScale, 0.80, 16),
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ToggleButtons(
                            isSelected: [_isSelected[0]],
                            onPressed: (int index) => _handleIslandSelection(0),
                            color: Colors.black,
                            selectedColor: Colors.purple,
                            fillColor: Colors.white,
                            selectedBorderColor: Colors.purple,
                            borderColor: Colors.black,
                            borderWidth: 2,
                            borderRadius: BorderRadius.circular(8),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  '1A',
                                  style: TextStyle(
                                      fontSize: getHintTextScale(
                                          currentScale, 0.75, 16),
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ToggleButtons(
                            isSelected: [_isSelected[1]],
                            onPressed: (int index) => _handleIslandSelection(1),
                            color: Colors.black,
                            selectedColor: Colors.purple,
                            fillColor: Colors.white,
                            selectedBorderColor: Colors.purple,
                            borderColor: Colors.black,
                            borderWidth: 2,
                            borderRadius: BorderRadius.circular(8),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  '3A',
                                  style: TextStyle(
                                      fontSize: getHintTextScale(
                                          currentScale, 0.75, 16),
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 42),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : _submitForm, // Disable button when submitting
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Request Pickup ->',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      getHintTextScale(currentScale, 0.50, 20),
                                ),
                              ),
                              if (_isSubmitting) // Show loader if submitting
                                const SizedBox(
                                  width: 16,
                                ),
                              if (_isSubmitting)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}
