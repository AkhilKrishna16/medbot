import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var health = HealthFactory(useHealthConnectIfAvailable: true);
  var caloriesBurned = 0.0;
  var totalSteps = 0;
  var newsList = [];

  Future<List> requestPastQueries() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      CollectionReference userQueriesSubcollection =
          userDocRef.collection('user_queries');

      QuerySnapshot querySnapshot = await userQueriesSubcollection.get();

      List<Map<String, dynamic>> queries = [];
      querySnapshot.docs.forEach(
        (doc) {
          queries.add({'query': doc['query'], 'date': doc['date']});
        },
      );

      return queries;
    } else {
      showBanner('Could not load queries.');
      return [];
    }
  }

  Future<List> requestNews(String query) async {
    String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String yesterday = DateFormat('dd/MM/yyyy')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    if (query == '') {
      return [];
    }

    final response = await http.post(
      Uri.parse('https://newsnow.p.rapidapi.com/newsv2'),
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': 'cc31192d44msh03a99c8d90443d6p11506djsn8eca8136b644',
        'X-RapidAPI-Host': 'newsnow.p.rapidapi.com',
      },
      body: jsonEncode(
        {
          'query': query,
          'page': 1,
          'time_bounded': true,
          'from_date': yesterday,
          'to_date': now,
          'location': '',
          'category': '',
          'source': '',
        },
      ),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      newsList = jsonResponse['news'].take(5).toList();

      return newsList;
    } else {
      throw Exception('Failed to load response.');
    }
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
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

  getSteps() async {
    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day);

    int? healthData = await health.getTotalStepsInInterval(midnight, now);

    await health.requestAuthorization(types, permissions: permissions);

    if (healthData != null) {
      setState(() {
        totalSteps = healthData.toDouble().round();
      });
    } else {
      totalSteps = 0;
    }
  }

  @override
  void initState() {
    super.initState();

    health.requestAuthorization(types);
    getCaloriesBurned();
    getSteps();

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
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 4.25 / 10 * width,
                      margin: EdgeInsets.only(
                        top: 1 / 30 * height,
                        left: 1 / 25 * width,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          1 / 45 * width,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1 / 90 * width,
                            blurRadius: 1 / 60 * width,
                            offset: Offset(
                              0,
                              1 / 150 * width,
                            ),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: SizedBox(
                        width: 2 / 5 * width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 1 / 32 * height,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1 / 150 * height),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  caloriesBurned.toString(),
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 1 / 20 * height,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'calories',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 1 / 35 * height,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1 / 2 * height,
                  width: 4.25 / 10 * width,
                  margin: EdgeInsets.only(
                    top: 1 / 30 * height,
                    left: 1 / 25 * width,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      1 / 45 * width,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1 / 90 * width,
                        blurRadius: 1 / 60 * width,
                        offset: Offset(
                          0,
                          1 / 150 * width,
                        ),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: FutureBuilder(
                    future: requestNews('Healthcare'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error'));
                      } else {
                        return SizedBox(
                          width: 4.5 / 10 * width,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  top: 1 / 50 * height,
                                  left: 1 / 50 * width,
                                  right: 1 / 50 * width,
                                ),
                                padding: EdgeInsets.only(
                                    left: 1 / 100 * width,
                                    right: 1 / 100 * width),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(1 / 50 * height),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1 / 90 * width,
                                      blurRadius: 1 / 60 * width,
                                      offset: Offset(
                                        0,
                                        1 / 150 * width,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        1 / 50 * height,
                                      ),
                                      child: Image.network(
                                        '${snapshot.data![index]['image']}',
                                        height: 1 / 15 * height,
                                        width: 1 / 7.5 * width,
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 1 / 100 * width,
                                          right: 1 / 90 * width,
                                        ),
                                        child: Text(
                                          '${snapshot.data![index]['title']}',
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 1 / 70 * height,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Column(
                  children: [
                    Container(
                      width: 4.25 / 10 * width,
                      margin: EdgeInsets.only(
                        top: 1 / 30 * height,
                        left: 1 / 25 * width,
                        right: 1 / 25 * width,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          1 / 45 * width,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1 / 90 * width,
                            blurRadius: 1 / 60 * width,
                            offset: Offset(
                              0,
                              1 / 150 * width,
                            ),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: SizedBox(
                        width: 2 / 5 * width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 1 / 32 * height,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1 / 150 * height),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  totalSteps.toString(),
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 1 / 20 * height,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'steps',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 1 / 35 * height,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1 / 2 * height,
                      width: 4.25 / 10 * width,
                      margin: EdgeInsets.only(
                        top: 1 / 30 * height,
                        left: 1 / 25 * width,
                        right: 1 / 25 * width,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          1 / 45 * width,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1 / 90 * width,
                            blurRadius: 1 / 60 * width,
                            offset: Offset(
                              0,
                              1 / 150 * width,
                            ),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: FutureBuilder(
                        future: requestPastQueries(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error'),
                            );
                          } else {
                            return SizedBox(
                              width: 4.5 / 10 * width,
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 1 / 50 * height,
                                          left: 1 / 50 * width,
                                        ),
                                        child: Text(
                                          '${snapshot.data![index]['date']}',
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 1 / 70 * height,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 1 / 150 * height,
                                          left: 1 / 50 * width,
                                          right: 1 / 50 * width,
                                        ),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                snapshot.data![index]['query'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 1 / 70 * height,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            return;
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('medical_ai_screen');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('news_generator_screen');
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed('settings_screen');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: '',
            backgroundColor: Colors.blue[200],
          ),
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
