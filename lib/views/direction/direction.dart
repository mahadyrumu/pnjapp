import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/views/home/homepage.dart';

class Direction extends StatefulWidget {
  const Direction({super.key});

  @override
  _DirectionState createState() => _DirectionState();
}

class _DirectionState extends State<Direction> {
  // Define the coordinates for the two locations
  final String _location1 = '47.43913773817353, -122.32347728049845';
  final String _location2 = '47.47791718815681, -122.31643312461328';

  static const platform = MethodChannel('com.example.app/maps');

  // Function to launch the native map application
  Future<void> _launchMap() async {
    try {
      await platform.invokeMethod('openMap', {
        'location1': _location1,
        'location2': _location2,
      });
    } on PlatformException catch (e) {
      print("Failed to open map: '${e.message}'.");
    }
  }

  // Function to launch the native map application for a single location
  Future<void> _launchSingleMap(String location) async {
    try {
      await platform.invokeMethod('openSingleMap', {'location': location});
    } on PlatformException catch (e) {
      print("Failed to open map: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directions'),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const HomePage(),
                  transition: Transition.leftToRight);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Displaying the image at the top of the screen with full-screen loader
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder(
                  future: precacheImage(
                    const NetworkImage(
                        'https://plg.parknjetseatac.com/_app/immutable/assets/map_contact.BQYieFHb.png'),
                    context,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.of(context)
                            .size
                            .height, // Full-screen loader
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {},
                        child: const Image(
                          image: AssetImage('assets/images/direction.png'),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              // First Card for Park N Jet Lot 1
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Park N Jet Lot 1:',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Address: 18220 8th Ave S SeaTac, WA 98148',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        Text(
                          'Hotline: (206) 241-6600',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        Text(
                          'Email: service@parknjetseatac.com',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        Text(
                          'Located: Southwest corner of Seatac International Airport',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        const SizedBox(height: 16),
                        // Full-width button with map marker icon
                        Center(
                          child: SizedBox(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _launchSingleMap(
                                    _location1); // Launch for Lot 1
                              },
                              icon: const Icon(
                                  Icons.location_on), // Map marker icon
                              label: Text(
                                'Directions',
                                textScaler: TextScaler.linear(
                                    getTextScale(currentScale, 1.65)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Second Card for Park N Jet Lot 2
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Park N Jet Lot 2:',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Address: 1244 S 140th St Seattle, WA 98168',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        Text(
                          'Phone: (206) 244-4500',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        Text(
                          'Email: service@parknjetseatac.com',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        Text(
                          'Located: Northwest corner of Seatac International Airport',
                          textScaler: TextScaler.linear(
                              getTextScale(currentScale, 1.65)),
                        ),
                        const SizedBox(height: 16),
                        // Full-width button with map marker icon
                        SizedBox(
                          child: Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _launchSingleMap(
                                    _location2); // Launch for Lot 2
                              },
                              icon: const Icon(
                                  Icons.location_on), // Map marker icon
                              label: Text(
                                'Directions',
                                textScaler: TextScaler.linear(
                                    getTextScale(currentScale, 1.65)),
                                textAlign: TextAlign.center,
                              ),
                            ),
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
}
