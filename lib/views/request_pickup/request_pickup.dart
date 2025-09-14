import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/services/request_pickup_service.dart';
import 'package:parknjet_app/models/request_pickup/request_pickup.dart';
import 'package:parknjet_app/views/home/homepage.dart';
import 'package:parknjet_app/views/request_pickup/create_request_pickup.dart';
import 'package:intl/intl.dart';

class ActivePickupRequestsPage extends StatefulWidget {
  const ActivePickupRequestsPage({super.key});

  @override
  State<ActivePickupRequestsPage> createState() =>
      _ActivePickupRequestsPageState();
}

class _ActivePickupRequestsPageState extends State<ActivePickupRequestsPage> {
  List<RequestPickupDataModel> _activePickupRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivePickupRequests();
  }

  Future<void> _loadActivePickupRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activePickupRequests =
          await RequestPickupService.fetchActivePickupRequest();
      print(activePickupRequests.length);
      if (activePickupRequests.isEmpty) {
        // Navigate to PickupRequestFormPage if no data found
        Get.off(
            () => const PickupRequestFormPage(
                  claimId: 0,
                  phone: "",
                ),
            transition: Transition.rightToLeft);
      } else {
        setState(() {
          _activePickupRequests = activePickupRequests;
        });
      }
    } catch (e) {
      print('Failed to load active pickup requests: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime convertToDateTime(String dateTimeString) {
    return DateTime.parse(dateTimeString).toLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading ? null : const Text('Active Pickup Requests'),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const HomePage(),
                  transition: Transition.leftToRight);
            },
            icon: Icon(Icons.arrow_back_ios)),
        automaticallyImplyLeading: !_isLoading, // Hide back button when loading
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: <Widget>[
                    _activePickupRequests.isEmpty
                        ? Material(
                            elevation: 5,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: Colors.grey[300],
                              width: double.infinity,
                              child: const Text(
                                "No Data Found!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Material(
                            elevation: 5,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: Colors.grey[300],
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildHeader('Date'),
                                  ),
                                  Expanded(
                                    child: _buildHeader('Claim ID'),
                                  ),
                                  Expanded(
                                    child: _buildHeader('Status'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),
                    ..._activePickupRequests.map((request) {
                      return Card(
                        elevation: 5,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero, // Remove border radius
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildText(
                                    DateFormat('yyyy-MM-dd hh:mm a').format(
                                        convertToDateTime(
                                            request.dateUpDated.toString())),
                                    true),
                              ),
                              Expanded(
                                child: _buildText(
                                    request.claimId.toString(), true),
                              ),
                              Expanded(
                                child: _buildText(
                                    request.parkingStatus.toString(), true),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: () {
                Get.to(
                    () => const PickupRequestFormPage(
                          claimId: 0,
                          phone: "",
                        ),
                    transition: Transition.rightToLeft);
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildText(String text, bool alignCenter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        text,
        textAlign: alignCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
