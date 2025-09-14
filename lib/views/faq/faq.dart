import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/views/home/homepage.dart';

class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  final List<Map<String, String>> faqLocation = [
    {
      'question': 'How far are you from the airport?',
      'answer':
          'We are approximately 1 mile from the Northwest side of Seattle-Tacoma International Airport.'
    },
    {
      'question':
          'How long will it take to get to Seattle-Tacoma International Airport from your lot?',
      'answer':
          'The drive time from our parking lot to Seattle-Tacoma International Airport is approximately 6-8 minutes.'
    },
    {
      'question': 'How frequent is the shuttle service?',
      'answer':
          'Our complimentary shuttle service runs 24x7 or on demand. Wait time could be up to 15 minutes if busy.'
    },
    {
      'question': 'How early should we arrive at your parking lot?',
      'answer':
          'You should arrive at our lot about 20-25 minutes from the time you would like to be at the airport terminal. You may want to give yourself some extra time to account for traffic, weather, and unexpected delays etc.'
    },
  ];
  final List<Map<String, String>> faqPrice = [
    {
      'question': 'When do I pay?',
      'answer':
          'You have an option to pay online or in-person when you drop-off your vehicle.'
    },
    {
      'question': 'What are the accepted methods of payment?',
      'answer':
          'When paying at check-in, we currently accept Visa, MasterCard, American Express, and Cash.'
    },
    {
      'question': 'What is the total price?',
      'answer':
          'When you place a reservation your total price is shown. We also send a confirmation email to you with the price.'
    },
    {
      'question': 'How do you calculate parking charges?',
      'answer': 'All rates are calculated in half day increments.'
    },
    {
      'question': 'Is there a minimum number of days that I have to park?',
      'answer': 'Our minimum charge is the price of parking for 2 days.'
    },
    {
      'question':
          'Will I be charged if I return a few hours after midnight the day after I was scheduled to return?',
      'answer':
          'You will be given a one hour grace period, after which you will be charged for half of a day at regular price (without discount).'
    },
  ];
  final List<Map<String, String>> faqCoupons = [
    {
      'question': 'I have a coupon. When do I need to give it to your staff?',
      'answer':
          'If you have a promotional code from your coupon, it is not necessary for you to print out the coupons because the discount is already reflected in the total amount given to you online. In any other case, any eligible coupon will be redeemed upon drop off time.'
    },
    {
      'question': 'Do you accept online coupons for walk-ins/drive-ups?',
      'answer':
          'No we do not accept coupons if you have not completed a web reservation online beforehand.'
    },
    {'question': 'Can multiple coupons be combined?', 'answer': 'No.'},
  ];
  final List<Map<String, String>> faqReservations = [
    {
      'question': 'Do I need a reservation?',
      'answer':
          'A reservation will guarantee you a parking stall and a better price because you can use our online discounts.'
    },
    {
      'question': 'What times should I enter for drop-off and pick-up?',
      'answer':
          'Please enter the times you plan to drop off and pickup your vehicle from the parking lot. You should plan to arrive at the parking lot 20 - 25 minutes before you want to arrive at the airport terminal (most airlines recommend arriving 2 hours prior to your scheduled flight). Select a pick up time that will allow you to pick up any checked baggage and catch a shuttle back to the parking lot. 30 to 45 minutes from the time your flight lands is sufficient in most cases.'
    },
    {
      'question':
          "What should I do if I don't receive an email confirming my reservation?",
      'answer':
          'You should receive email confirmation within 5 to 10 minutes after completing your reservation. You may want to check that the email you provided for your reservation is correct and our email was not sent to your spam or bulk mail folder. If you still have not received an email, contact us at service@parknjetseatac.com'
    },
    {
      'question': 'How do I cancel a reservation that I made beforehand?',
      'answer':
          'All cancelations must be submitted by midnight of the day before you are planning to drop-off your vehicle. To cancel or modify your reservation, please email us at service@parknjetSeaTac.com Include your name and reservation number which you received in your confirmation email.'
    },
    {
      'question': 'How do I extend a checked in reservation?',
      'answer': '''There are 3 ways to extend a reservation:
1. The most economical option is to buy a prepaid package and email us at service@parknjetseatac.com. We will redeem the necessary days from the package to extend the checked-in reservation.
2. You can make a new reservation on our website (http://www.parknjetseatac.com) for the extended period of time, in case it is to be extended for more than a day. Please send us the new reservation along with the checked-in reservation so that we can extend it.
3. If you choose not to extend the checked-in reservation, you will be charged the regular undiscounted price up to \$40.00 for each unreserved/late day.'''
    },
  ];
  final List<Map<String, String>> faqGeneralInformation = [
    {
      'question':
          'What are your hours of operation? Do you close on any holidays?',
      'answer': 'We are open 24/7. We never close, we are open 365 days a year.'
    },
    {
      'question': 'How do you know to pick me up at the airport?',
      'answer':
          '''Please call us at the facility number on your claim ticket (given at check-in) after you have claimed your luggage.

- Park n Jet Lot-1: 206-241-6600
- Park n Jet Lot-2: 206-244-4500

If you do not have a cell phone, you may call us from a courtesy phone by dialing:

- *71 for Park n Jet Lot-1.
- *91 for Park n Jet Lot-2.'''
    },
    {
      'question': 'Should I leave my valuables in my car?',
      'answer':
          "We suggest that you don't but if you chose to, we are not responsible for theft or damage to a vehicle or its contents, unless it occurs through the sole negligence of our staff."
    },
    {
      'question':
          'I have a lot of luggage, should I check it in first and then park my car?',
      'answer':
          'Some customers choose to drop their luggage off at the airport before parking their car.'
    },
    {
      'question': 'What if my vehicle is over sized?',
      'answer':
          'Park N Jet reserves the right to decline or charge a surcharge on certain over sized or modified vehicles.'
    },
    {
      'question': 'Will you help me with my luggage?',
      'answer':
          "Yes we do. Please ask our staff for assistance if you'd like help."
    },
    {
      'question': 'Do you have a loyalty/rewards program?',
      'answer':
          'Yes we do! For all PNJ members, they get 10 pts for every dollar they spend, and 1500 points is equal to one free day of parking. We also have an extra rewards option where you can buy extra points and take advantage of our rewards multiplier!'
    },
  ];

  // Track the expansion state of each list
  List<bool> _expandedLocation = [];
  List<bool> _expandedPrice = [];
  List<bool> _expandedCoupons = [];
  List<bool> _expandedReservations = [];
  List<bool> _expandedGeneralInformation = [];

  @override
  void initState() {
    super.initState();
    // Initialize all lists with false values (collapsed state)
    _expandedLocation = List<bool>.filled(faqLocation.length, false);
    _expandedPrice = List<bool>.filled(faqPrice.length, false);
    _expandedCoupons = List<bool>.filled(faqCoupons.length, false);
    _expandedReservations = List<bool>.filled(faqReservations.length, false);
    _expandedGeneralInformation =
        List<bool>.filled(faqGeneralInformation.length, false);
  }

  _buildCardWidget(List<Map<String, String>> data, List<bool> expandedList,
      int index, currentScale) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: Column(
        children: [
          Container(
            color: Colors.grey[200], // Set the background color of the header
            child: ListTile(
              title: Text(
                data[index]['question']!,
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              ),
              trailing: Icon(
                expandedList[index]
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
              ),
              onTap: () {
                setState(() {
                  expandedList[index] = !expandedList[index];
                });
              },
            ),
          ),
          // Conditionally render answer content if expanded
          if (expandedList[index])
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                data[index]['answer']!,
                textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
        leading: IconButton(
            onPressed: () {
              Get.to(() => const HomePage(),
                  transition: Transition.leftToRight);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Location',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildCardWidget(
                      faqLocation, _expandedLocation, index, currentScale);
                },
                childCount: faqLocation.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Price',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildCardWidget(
                      faqPrice, _expandedPrice, index, currentScale);
                },
                childCount: faqPrice.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Coupons',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildCardWidget(
                      faqCoupons, _expandedCoupons, index, currentScale);
                },
                childCount: faqCoupons.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Reservations',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildCardWidget(faqReservations,
                      _expandedReservations, index, currentScale);
                },
                childCount: faqReservations.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'General Information',
                  textScaler:
                      TextScaler.linear(getTextScale(currentScale, 1.65)),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildCardWidget(faqGeneralInformation,
                      _expandedGeneralInformation, index, currentScale);
                },
                childCount: faqGeneralInformation.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
