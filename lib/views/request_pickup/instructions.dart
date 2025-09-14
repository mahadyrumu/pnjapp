import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/views/home/homepage.dart'; // Import the HomePage

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                'Instructions:',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Make sure you are at Island 1A/3A within the time you specified.',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              Text(
                '2. Wave your hand when you see our shuttle so that the driver can recognize you.',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              Text(
                '3. Please be patient if the shuttle is full. Our dispatch system knows you are waiting and we will send another shuttle in a very short time.',
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              const Spacer(), // Use Spacer to push the button to the bottom
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const HomePage(),
                        transition: Transition.leftToRight);
                  },
                  label: Text(
                    'Back to Home',
                    textScaler:
                        TextScaler.linear(getTextScale(currentScale, 1.65)),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
