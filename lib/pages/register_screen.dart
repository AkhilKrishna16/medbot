import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  double opacity = 0.0;

  var auth = FirebaseAuth.instance;

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

  Future<bool> registerUser(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final prefs = await SharedPreferences.getInstance();

      prefs.setBool('autoLogin', true);
      prefs.setString('email', email);
      prefs.setString('password', password);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        setState(
          () {
            opacity = 1.0;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    var isLoading = false;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(seconds: 1),
            child: Padding(
              padding: EdgeInsets.only(
                top: 1 / 9 * height,
                left: 1 / 19 * width,
                right: 1 / 19 * width,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MedBot',
                            style: TextStyle(
                              fontSize: 1 / 23 * height,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          Text(
                            'Your Personal Health Assistant',
                            style: TextStyle(
                              fontSize: 1 / 55 * height,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/images/MedBot.png',
                        height: 1 / 6.9 * height,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1 / 24 * height,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 1 / 38 * height,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      SizedBox(height: 1 / 100 * height),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          autocorrect: false,
                          controller: _nameController,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 1 / 50 * height,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your new name',
                            hintStyle: TextStyle(
                              fontSize: 1 / 50 * height,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 1 / 40 * width,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1 / 100 * height),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 1 / 38 * height,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      SizedBox(height: 1 / 100 * height),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          autocorrect: false,
                          controller: _emailController,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 1 / 50 * height,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your new email',
                            hintStyle: TextStyle(
                              fontSize: 1 / 50 * height,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 1 / 40 * width,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1 / 60 * height,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 1 / 38 * height,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      SizedBox(height: 1 / 100 * height),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 1 / 50 * height,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your new password',
                            hintStyle: TextStyle(
                              fontSize: 1 / 50 * height,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 1 / 40 * width),
                            border: InputBorder.none,
                          ),
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1 / 20 * height,
                  ),
                  MaterialButton(
                    onHighlightChanged: (isHighlighted) {
                      setState(() {
                        opacity = isHighlighted ? 0.6 : 1.0;
                      });
                    },
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      if (_emailController.text != '' &&
                          _passwordController.text != '') {
                        registerUser(
                                _emailController.text, _passwordController.text)
                            .then((value) {
                          if (value) {
                            String? userId = auth.currentUser?.uid;

                            if (userId != null) {
                              try {
                                firestore.collection('users').doc(userId).set(
                                  {
                                    'name': _nameController.text,
                                    'email': _emailController.text,
                                    'password': _passwordController.text,
                                  },
                                );
                              } catch (e) {
                                showBanner(context, 'Error: $e');
                                return;
                              }
                            }
                            Future.delayed(
                              const Duration(seconds: 2),
                              () {
                                Navigator.pushReplacementNamed(
                                    context, 'home_page');
                              },
                            );
                          } else {
                            Future.delayed(
                              const Duration(seconds: 2),
                              () {
                                setState(
                                  () {
                                    isLoading = false;
                                  },
                                );

                                showBanner(
                                    context, 'Improper register details.');
                              },
                            );
                          }
                        });
                      } else {
                        showBanner(context,
                            'Make sure to enter a username and password!');
                        setState(
                          () {
                            isLoading = false;
                          },
                        );
                      }
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLoading ? 1 / 5 * width : 1 / 10 * width,
                        vertical: 1 / 160 * height,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isLoading ? Colors.grey[300] : Colors.blue[200],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        isLoading ? 'Loading...' : 'Register',
                        style: TextStyle(
                          fontSize: 1 / 38 * height,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1 / 20 * height,
                  ),
                  Row(
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 1 / 60 * height,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, 'login_screen');
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 1 / 60 * height,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
