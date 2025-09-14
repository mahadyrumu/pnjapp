import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/quotes_controller.dart';
import 'package:parknjet_app/services/get_token.dart';
import 'package:parknjet_app/services/mem_quotes.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckAvailability extends StatefulWidget {
  const CheckAvailability({super.key});

  @override
  State<CheckAvailability> createState() => _CheckAvailabilityState();
}

class _CheckAvailabilityState extends State<CheckAvailability> {
  final TextEditingController _dateRangeController = TextEditingController();
  final TextEditingController _checkInTimeController = TextEditingController();
  final TextEditingController _checkOutTimeController = TextEditingController();

  String _selectedLot = 'ANY';
  String _selectedVehicleLength = 'Under 17ft.'; // Default value
  var lotOne = {};
  var lotTwo = {};
  var lotOneSelf = {};
  var lotOneValet = {};
  var lotTwoSelf = {};
  var lotTwoValet = {};
  final _quoteController = Get.put(QuotesController());

  List<String> _vehicleLengthOptions = [
    'Under 17ft.',
    '17-19ft.',
    '19-21ft.',
  ];

  @override
  void initState() {
    super.initState();
    // Default today and tomorrow's date, and default time to 12:00 PM
    final today = DateTime.now().add(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 4));

    _dateRangeController.text =
        '${DateFormat('yyyy-MM-dd').format(today)} to ${DateFormat('yyyy-MM-dd').format(tomorrow)}';
    _checkInTimeController.text = '12:00 PM';
    _checkOutTimeController.text = '12:00 PM';
  }

  _setVehicleLengthOption() {
    if (_selectedLot != "LOT_1") {
      setState(() {
        _vehicleLengthOptions = [
          'Under 17ft.',
          '17-19ft.',
          '19-21ft.',
        ];
      });
    } else {
      setState(() {
        _selectedVehicleLength = 'Under 17ft.';
        _vehicleLengthOptions = ['Under 17ft.', '17-19ft.'];
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: DateTime.now().add(const Duration(days: 1)),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
    );

    if (pickedDateRange != null) {
      setState(() {
        _dateRangeController.text =
            '${DateFormat('yyyy-MM-dd').format(pickedDateRange.start)} to ${DateFormat('yyyy-MM-dd').format(pickedDateRange.end)}';
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0), // Default to 12:00 PM
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        final formattedTime = DateFormat('hh:mm a').format(DateTime(
            now.year, now.month, now.day, pickedTime.hour, pickedTime.minute));
        controller.text = formattedTime;
      });
    }
  }

  Map<String, dynamic> _buildPayload(String doDate, String puDate) {
    return {
      'doDate': doDate,
      'puDate': puDate,
      'vehicleLength': _getVehicleLength(),
      'couponCode': null,
      'lot': _selectedLot.toString(),
    };
  }

  String _getVehicleLength() {
    switch (_selectedVehicleLength) {
      case '17-19ft.':
        return 'LARGE';
      case '19-21ft.':
        return 'EXTRA_LARGE';
      default:
        return 'STANDARD';
    }
  }

  Future<void> _searchAvailability() async {
    setState(() {
      lotOne = {};
      lotTwo = {};
      lotOneSelf = {};
      lotOneValet = {};
      lotTwoSelf = {};
      lotTwoValet = {};
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    final String doDate =
        '${_dateRangeController.text.split(' to ')[0]} ${_checkInTimeController.text}';
    final String puDate =
        '${_dateRangeController.text.split(' to ')[1]} ${_checkOutTimeController.text}';

    Map<String, dynamic> payload = _buildPayload(doDate, puDate);

    try {
      // _quotes = await _quoteController.fetchQuote(payload);
      final quotes = await QuoteService().fetchQuotes(payload);

      setState(() {
        if (quotes.containsKey('LOT_1')) {
          lotOne = quotes['LOT_1'];
          if (lotOne.containsKey('VALET')) {
            lotOneValet = lotOne['VALET'];
          }
          if (lotOne.containsKey('SELF')) {
            lotOneSelf = lotOne['SELF'];
          }
        }
        if (quotes.containsKey('LOT_2')) {
          lotTwo = quotes['LOT_2'];
          if (lotTwo.containsKey('VALET')) {
            lotTwoValet = lotTwo['VALET'];
          }
          if (lotTwo.containsKey('SELF')) {
            lotTwoSelf = lotTwo['SELF'];
          }
        }
      });
      Navigator.of(context).pop();
    } catch (e) {
      _quoteController.quoteErrorMessage.value = 'Failed to fetch quotes: $e';
      Navigator.of(context).pop();
    }
  }

  Future<void> _launchUrl(lotType, parkingType, paymentType) async {
    // print(_dateRangeController.text.split(' to ')[1]);
    final String doDate = _dateRangeController.text.split(' to ')[0];
    final String puDate = _dateRangeController.text.split(' to ')[1];

    final String doTime = _checkInTimeController.text;
    final String puTime = _checkOutTimeController.text;
    String? token = await GetToken.getToken();
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    int? userId = sharedPreferences.getInt("userId");

    // print(doDate);
    // print(puDate);
    // print(doTime);
    // print(puTime);
    // print(parkingType);
    // print(_getVehicleLength().toString());

    final Uri _url = Uri.parse(
        'https://plg.parknjetseatac.com/availability/redirect-from-app?doDate=$doDate&doTime=$doTime&puDate=$puDate&puTime=$puTime&pref=${parkingType.toUpperCase()}&vehicleLength=${_getVehicleLength()}&lot=$lotType&coupon=&walletDays=&token=$token&id=$userId&paymentType=$paymentType');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _launchQuestionUrl() async {
    final Uri _url = Uri.parse(
        'https://plg.parknjetseatac.com/how-does-airport-parking-work');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Widget _buildQuotesCard(currentScale) {
    if (lotOne.isEmpty && lotTwo.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: [
                Text(
                  "Search results for dates from",
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  " ${_dateRangeController.text.split(' to ')[0]}",
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  " to",
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  " ${_dateRangeController.text.split(' to ')[1]}",
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              if (lotOne.isNotEmpty)
                if (lotOneValet.isNotEmpty)
                  _buildQuoteCardForLot(
                      lotOneValet, 'Lot 1', 'Valet', currentScale),
              if (lotOneSelf.isNotEmpty)
                _buildQuoteCardForLot(
                    lotOneSelf, 'Lot 1', 'Self', currentScale),
              if (lotTwo.isNotEmpty)
                if (lotTwoValet.isNotEmpty)
                  _buildQuoteCardForLot(
                      lotTwoValet, 'Lot 2', 'Valet', currentScale),
              if (lotTwoSelf.isNotEmpty)
                _buildQuoteCardForLot(
                    lotTwoSelf, 'Lot 2', 'Self', currentScale),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCardForLot(
      quote, String lotName, String parkingType, currentScale) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$lotName - $parkingType Parking',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                "Park N Jet $lotName",
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              ),
              Gap(5),
              currentScale > 1.353
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildQuoteButton(
                              '\$${quote['online']['total']} - Pay Now', () {
                            _launchUrl(quote['lotType'], parkingType, "online");
                          }, currentScale),
                          _buildQuoteButton(
                              '\$${quote['nonOnline']['total']} - Pay At Lot',
                              () {
                            _launchUrl(
                                quote['lotType'], parkingType, "offline");
                          }, currentScale),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuoteButton(
                              '\$${quote['online']['total']} - Pay Now', () {
                            _launchUrl(quote['lotType'], parkingType, "online");
                          }, currentScale),
                          _buildQuoteButton(
                              '\$${quote['nonOnline']['total']} - Pay At Lot',
                              () {
                            _launchUrl(
                                quote['lotType'], parkingType, "offline");
                          }, currentScale),
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  _buildQuoteButton(String text, VoidCallback onPressed, currentScale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * .8,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(width: 1.0, color: Colors.red),
          backgroundColor: Colors.red[100],
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textScaler: TextScaler.linear(getTextScale(currentScale, 1.48)),
            style: TextStyle(
                fontSize: 16,
                color: Colors.red[900],
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }

  void _showHowToChoseCheckOutTimeModal(
      BuildContext context, screenHeight, currentScale) {
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows dismissing the modal by tapping outside
      enableDrag: true, // Allows swiping down to dismiss
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 0.40 * screenHeight, // Set the height of the modal
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'If your flight land at 2 PM, consider selecting a check-out time of 3 PM to allow ample time for check-out and security procedures.',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHowToChoseCheckInTimeModal(
      BuildContext context, screenHeight, currentScale) {
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Allows dismissing the modal by tapping outside
      enableDrag: true, // Allows swiping down to dismiss
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 0.40 * screenHeight, // Set the height of the modal
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                'If your flight is at 3 PM, consider selecting a check-in time of 12:30 PM to allow ample time for check-in and security procedures.',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Make New Reservation',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.40)),
        ),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const HomePage(),
                  transition: Transition.leftToRight);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Friendly staff offers best parking experience',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _launchQuestionUrl();
                  },
                  child: Text(
                    'How does Airport Parking work?',
                    textScaler:
                        TextScaler.linear(getTextScale(currentScale, 1.65)),
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _showHowToChoseCheckInTimeModal(
                        context, screenHeight, currentScale);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'How to choose Check-in time?',
                      textScaler:
                          TextScaler.linear(getTextScale(currentScale, 1.65)),
                      style: const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _showHowToChoseCheckOutTimeModal(
                        context, screenHeight, currentScale);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'How to choose Check-out time?',
                      textScaler:
                          TextScaler.linear(getTextScale(currentScale, 1.65)),
                      style: const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Gap(40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    TextFormField(
                      controller: _dateRangeController,
                      readOnly: true,
                      style: TextStyle(
                        fontSize: getHintTextScale(currentScale, 0.55, 18),
                      ),
                      decoration: InputDecoration(
                          labelText: 'Check-In / Check-Out Dates',
                          labelStyle: TextStyle(
                              fontSize:
                                  getHintTextScale(currentScale, 0.60, 20)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Image.asset(
                              'assets/Icons/in_out.png',
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 45, // Minimum width
                            minHeight: 45, // Minimum height
                            maxWidth: 45, // Maximum width
                            maxHeight: 45, // Maximum height
                          ),
                          border: const OutlineInputBorder()),
                      onTap: () => _selectDateRange(context),
                    ),
                    Obx(() {
                      return _quoteController.quoteErrorMessage.value != ""
                          ? Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                _quoteController.quoteErrorMessage.value,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : Container();
                    }),
                    Gap(15),

                    // Check-In Time
                    TextFormField(
                      controller: _checkInTimeController,
                      readOnly: true,
                      style: TextStyle(
                        fontSize: getHintTextScale(currentScale, 0.55, 18),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Check-In Time',
                        labelStyle: TextStyle(
                            fontSize: getHintTextScale(currentScale, 0.60, 20)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(Icons.access_time),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 45, // Minimum width
                          minHeight: 45, // Minimum height
                          maxWidth: 45, // Maximum width
                          maxHeight: 45, // Maximum height
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onTap: () => _selectTime(context, _checkInTimeController),
                    ),
                    Gap(15),

                    // Check-Out Time
                    TextFormField(
                      controller: _checkOutTimeController,
                      readOnly: true,
                      style: TextStyle(
                        fontSize: getHintTextScale(currentScale, 0.55, 18),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Check-Out Time',
                        labelStyle: TextStyle(
                            fontSize: getHintTextScale(currentScale, 0.60, 20)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: const Icon(Icons.access_time),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 45, // Minimum width
                          minHeight: 45, // Minimum height
                          maxWidth: 45, // Maximum width
                          maxHeight: 45, // Maximum height
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onTap: () =>
                          _selectTime(context, _checkOutTimeController),
                    ),
                    Gap(15),

                    // Park N Jet Lot
                    DropdownButtonFormField<String>(
                      value: _selectedLot,
                      decoration: InputDecoration(
                        labelText: 'Park N Jet Lot',
                        labelStyle: TextStyle(
                            fontSize: getHintTextScale(currentScale, 0.65, 20)),
                        border: const OutlineInputBorder(),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/Icons/lot.png',
                            height: 5, // Adjust height to fit
                            width: 5, // Adjust width to fit
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 45, // Minimum width
                          minHeight: 45, // Minimum height
                          maxWidth: 45, // Maximum width
                          maxHeight: 45, // Maximum height
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'ANY',
                          child: Text(
                            'Any',
                            style: TextStyle(
                              fontSize:
                                  getHintTextScale(currentScale, 0.55, 18),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'LOT_1',
                          child: Text(
                            'Parking Lot-1',
                            style: TextStyle(
                              fontSize:
                                  getHintTextScale(currentScale, 0.55, 18),
                            ),
                            textScaler: TextScaler.linear(
                                getTextScale(currentScale, 1.65)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'LOT_2',
                          child: Text(
                            'Parking Lot-2',
                            style: TextStyle(
                              fontSize:
                                  getHintTextScale(currentScale, 0.55, 18),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLot = newValue!;
                          _setVehicleLengthOption();
                        });
                      },
                    ),
                    Gap(15),

                    // Vehicle Length
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleLength,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Length',
                        labelStyle: TextStyle(
                          fontSize: getHintTextScale(currentScale, 0.65, 20),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/Icons/length.png',
                            height: 5, // Adjust height to fit
                            width: 5, // Adjust width to fit
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 45, // Minimum width
                          minHeight: 45, // Minimum height
                          maxWidth: 45, // Maximum width
                          maxHeight: 45, // Maximum height
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: _vehicleLengthOptions.map((String option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize:
                                  getHintTextScale(currentScale, 0.55, 18),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedVehicleLength = newValue!;
                        });
                      },
                    ),

                    Gap(20),
                    Center(
                        child: SizedBox(
                      height: screenHeight * .055,
                      width: screenWidth * 1,
                      child: ElevatedButton(
                        onPressed: _searchAvailability,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(5)), // Removes border radius
                          ),
                        ),
                        child: Text(
                          'Search',
                          style: TextStyle(fontSize: 20),
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                      ),
                    )),
                  ],
                ),
                _buildQuotesCard(currentScale),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
