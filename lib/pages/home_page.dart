import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var health = HealthFactory(useHealthConnectIfAvailable: true);
  var caloriesBurned = 0.0;
  Future<String> requestNews() async {
    String now = DateFormat('MM/dd/yyyy').format(DateTime.now());
    String threeMonthsAgo = DateFormat('MM/dd/yyyy')
        .format(DateTime.now().subtract(const Duration(days: 90)));

    final response = await http.post(
      Uri.parse('https://newsnow.p.rapidapi.com/newsv2'),
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': 'ec4da37c5cmshd0dccdd2ed69f23p1ee5fbjsnc40f03b5fe2c',
        'X-RapidAPI-Host': 'newsnow.p.rapidapi.com',
      },
      body: jsonEncode(
        {
          'query': 'Medical AI',
          'page': 1,
          'time_bounded': true,
          'from_date': threeMonthsAgo,
          'to_date': now,
          'location': '',
          'category': '',
          'source': '',
        },
      ),
    );

    return response.body[0];
  }

  void showBanner(String message) {
    var height = MediaQuery.of(context).size.height;

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'DM Sans',
          fontSize: 1 / 50 * height,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red[300], // Customize the background color
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var types = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.STEPS,
  ];

  var permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  void getCaloriesBurned() async {
    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day);
    var strings = [];

    await health.requestAuthorization(types, permissions: permissions);

    List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(midnight, now, [types[0]]);

    if (healthData.isEmpty) {
      showBanner('No data available. Log some calories into the Health app!');
      return;
    }

    for (var dataPoint in healthData) {
      strings.add(dataPoint.value.toString());
    }

    for (var string in strings) {
      caloriesBurned += double.parse(string).round();
    }

    setState(() {
      caloriesBurned = caloriesBurned;
    });
  }

  @override
  void initState() {
    super.initState();

    health.requestAuthorization(types);

    getCaloriesBurned();

    // requestNews();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 1 / 24 * width),
          child: Row(
            children: [
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 1 / 20 * height,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        elevation: 0.0,
        toolbarHeight: 1 / 10 * height,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 1 / 100 * height,
                      spreadRadius: 1 / 100 * height,
                      offset: Offset(0, 1 / 100 * height),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: '',
              backgroundColor: Colors.blue[200]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: '',
              backgroundColor: Colors.blue[200]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.local_hospital),
              label: '',
              backgroundColor: Colors.blue[200]),
          BottomNavigationBarItem(
            icon: const Icon(Icons.newspaper),
            label: '',
            backgroundColor: Colors.blue[200],
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: '',
              backgroundColor: Colors.blue[200]),
        ],
      ),
    );
  }
}
