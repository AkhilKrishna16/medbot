import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class NewsGeneratorScreen extends StatefulWidget {
  const NewsGeneratorScreen({super.key});

  @override
  State<NewsGeneratorScreen> createState() => _NewsGeneratorScreenState();
}

class _NewsGeneratorScreenState extends State<NewsGeneratorScreen> {
  var newsList = [];
  var queryController = TextEditingController();

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
      newsList = jsonResponse['news'].take(15).toList();
      return newsList;
    } else {
      throw Exception('Failed to load response.');
    }
  }

  void showBanner(BuildContext context, String message) {
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

  void showGoodBanner(BuildContext context, String message) {
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
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green[300], // Customize the background color
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Padding(
          padding: EdgeInsets.only(left: 1 / 100 * width),
          child: Row(
            children: [
              Text(
                'Today\'s News',
                style: TextStyle(
                  fontSize: 1 / 22 * height,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
        toolbarHeight: 1 / 10 * height,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 1 / 30 * height,
              left: 1 / 25 * width,
              right: 1 / 25 * width,
              bottom: 1 / 60 * height,
            ),
            padding: EdgeInsets.only(
              left: 1 / 30 * width,
              right: 1 / 40 * width,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 1 / 100 * height,
                  spreadRadius: 1 / 200 * height,
                  offset: Offset(0, 1 / 300 * height),
                ),
              ],
              borderRadius: BorderRadius.circular(1 / 50 * height),
            ),
            child: TextField(
              controller: queryController,
              decoration: const InputDecoration(
                hintText: 'Search for medical news',
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 1 / 50 * height,
                fontWeight: FontWeight.bold,
              ),
              onEditingComplete: () {
                setState(
                  () {
                    setState(
                      () {
                        requestNews(queryController.text);
                      },
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 1 / 100 * height),
          Expanded(
            child: FutureBuilder(
              future: requestNews(queryController.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  return Container(
                    padding: EdgeInsets.only(bottom: 1 / 25 * height),
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 1 / 40 * height),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        return MaterialButton(
                          onPressed: () {
                            _launchURL(
                              Uri.parse(
                                newsList[index]['url'],
                              ),
                            );
                          },
                          child: Container(
                            height: 1 / 7 * height,
                            width: width,
                            padding: EdgeInsets.only(
                              left: 1 / 30 * width,
                              right: 1 / 30 * width,
                            ),
                            margin: EdgeInsets.only(
                              left: 1 / 40 * width,
                              right: 1 / 40 * width,
                              bottom: 1 / 45 * height,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 1 / 100 * height,
                                  spreadRadius: 1 / 200 * height,
                                  offset: Offset(0, 1 / 300 * height),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(
                                1 / 50 * height,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    1 / 50 * height,
                                  ),
                                  child: Image.network(
                                    '${newsList[index]['image']}',
                                    height: 1 / 10 * height,
                                    width: 1 / 5 * width,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 1 / 100 * height,
                                    left: 1 / 27 * width,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width: 4 / 7 * width,
                                          child: Text(
                                            '${newsList[index]['title']}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 1 / 65 * height,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: SizedBox(
                                          width: 4 / 7 * width,
                                          child: Text(
                                            '${newsList[index]['body']}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 1 / 70 * height,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1 / 100 * height),
                                      Flexible(
                                        child: SizedBox(
                                          width: 4 / 7 * width,
                                          child: Text(
                                            '${newsList[index]['source']}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 1 / 65 * height,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('home_page');
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('medical_ai_screen');
          } else if (index == 2) {
            return;
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

// // Launching lib/main.dart on iPhone 14 Pro Max in debug mode...
// // Xcode build done.                                           26.6s
// [VERBOSE-2:FlutterDarwinContextMetalImpeller.mm(37)] Using the Impeller rendering backend.
// Connecting to VM Service at ws://127.0.0.1:53713/2rpFuDVQulc=/ws
// flutter: 01/10/2023
// flutter: 30/09/2023
// flutter: [{title: Can AI Tear Down Healthcareâs Data Silos?, body: In healthcare, communication and coordination are often weak. This is a problem that's bedeviled patient care teams, the health insurance / healthcare..., date: 15 mins ago, url: https://www.forbes.com/sites/stephenwunker/2023/10/01/can-ai-tear-down-healthcares-data-silos/, source: Forbes, image: https://audiospace-1-u9912847.deta.app/getnewspic?id=7bC5eHuOXgTQcBjLvCrp1696184482.7146564}, {title: Comparing ChatGPT and GPT-4 performance in USMLE soft ..., body: ... medicine. Introduction. Artificial intelligence (AI) is revolutionizing patient care and medical research. AI algorithms are being rapidly introduced and..., date: 9 hours ago, url: https://www.nature.com/articles/s41598-023-43436-9, source: Nature, image: https://audiospace-1-u9912847.deta.app/getnewspic?id=xZMhuShRt6LWRDK7uS4g1696184482.7843664}, {title: [Game Changer] Lunit on how AI can revolutionize cancer ..., body: âJust like self-driving cars, an era <…>
