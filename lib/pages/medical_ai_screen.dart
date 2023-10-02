import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MedicalAIScreen extends StatefulWidget {
  const MedicalAIScreen({super.key});

  @override
  State<MedicalAIScreen> createState() => _MedicalAIScreenState();
}

class _MedicalAIScreenState extends State<MedicalAIScreen> {
  final symptomController = TextEditingController();

  Future<void> addUserQuery(String query) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final CollectionReference userQueriesCollection =
          FirebaseFirestore.instance.collection('users');

      DocumentReference userDocRef = userQueriesCollection.doc(user.uid);

      CollectionReference userQueriesSubcollection =
          userDocRef.collection('user_queries');

      await userQueriesSubcollection.add(
        {
          'query': query,
          'date': DateFormat('MM/dd/yyyy').format(
            DateTime.now(),
          ),
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    } else {
      showBanner(context, 'User is null');
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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Padding(
          padding: EdgeInsets.only(left: 1 / 100 * width),
          child: Row(
            children: [
              Text(
                'Medical AI',
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
      body: Padding(
        padding: EdgeInsets.only(
          left: 1 / 60 * width,
          right: 1 / 60 * width,
          top: 1 / 60 * height,
        ),
        child: Column(
          children: [
            Text(
              'Welcome to MedBot.ai! Enter your symptoms below to get started. We produce a diagnosis based on your symptoms and a confidence score to let you know how confident we are in our results. Furthermore, we utilize LLMs to give you advice on what you should do once you get your diagnosis.',
              style: TextStyle(
                fontSize: 1 / 55 * height,
                fontWeight: FontWeight.bold,
                fontFamily: 'DM Sans',
              ),
            ),
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
                controller: symptomController,
                decoration: const InputDecoration(
                  hintText: 'Enter your symptoms here...',
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 1 / 50 * height,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 1 / 20 * height,
            ),
            MaterialButton(
              onPressed: () {
                if (symptomController.text == '') {
                  showBanner(context, 'Please enter your symptoms!');
                } else {
                  addUserQuery(symptomController.text);
                  Navigator.pushNamed(
                    context,
                    'diagnosis_screen',
                    arguments: symptomController.text,
                  );
                }
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Container(
                height: 1 / 15 * height,
                width: 1 / 3 * width,
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(1 / 50 * height),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 1 / 100 * height,
                      spreadRadius: 1 / 200 * height,
                      offset: Offset(0, 1 / 300 * height),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Diagnose',
                    style: TextStyle(
                      fontSize: 1 / 50 * height,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('home_page');
          } else if (index == 1) {
            return;
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
