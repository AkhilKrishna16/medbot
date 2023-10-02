import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoLogin = false;

  void showBanner(String message, Color color) {
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
      duration: const Duration(seconds: 1, milliseconds: 500),
      backgroundColor: color, // Customize the background color
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot<Map<String, dynamic>> userData =
          await userDocRef.get() as DocumentSnapshot<Map<String, dynamic>>;

      print(userData);

      return userData;
    }
    throw Exception('User not found');
  }

  Future<void> loadAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        autoLogin = prefs.getBool('autoLogin') ?? false;
      },
    );
  }

  Future<void> saveAutoLogin(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', value);
  }

  @override
  void initState() {
    super.initState();
    loadAutoLogin();
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
                'Settings',
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
      body: Container(
        width: width,
        padding: EdgeInsets.only(
          left: 1 / 60 * width,
          right: 1 / 60 * width,
          top: 1 / 30 * height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1 / 200 * width,
                    blurRadius: 1 / 200 * width,
                    offset: Offset(
                        0, 1 / 200 * width), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(1 / 30 * height),
                ),
              ),
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: _loadUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Error');
                  } else {
                    final userData = snapshot.data?.data();
                    if (userData == null) {
                      return const Center(
                        child: Text('User data not found!'),
                      );
                    }

                    final username = userData['name'] as String?;
                    final email = userData['email'] as String?;

                    if (username != null && email != null) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: 1 / 50 * width,
                            right: 1 / 50 * width,
                            top: 1 / 50 * height,
                            bottom: 1 / 50 * height),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DM Sans',
                                fontSize: 1 / 40 * height,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              email,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DM Sans',
                                fontSize: 1 / 50 * height,
                                color: Colors.grey[600],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  return const Center(
                    child: Text('User data not found!'),
                  );
                },
              ),
            ),
            SizedBox(height: 1 / 30 * height),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auto Login',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                    fontSize: 1 / 30 * height,
                  ),
                ),
                CupertinoSwitch(
                  value: autoLogin,
                  onChanged: (value) {
                    setState(
                      () {
                        autoLogin = value;
                      },
                    );
                    saveAutoLogin(value);
                  },
                )
              ],
            ),
            SizedBox(
              height: 1 / 20 * height,
            ),
            MaterialButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Container(
                width: 2 / 3 * width,
                height: 1 / 15 * height,
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(1 / 30 * height),
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
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 1 / 32 * height,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                saveAutoLogin(false);
                FirebaseAuth.instance.signOut();

                Navigator.pushNamedAndRemoveUntil(
                    context, 'login_screen', (route) => false);
                showBanner('Logged out successfully!', Colors.green);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('home_page');
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('medical_ai_screen');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('news_generator_screen');
          } else if (index == 3) {
            return;
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
