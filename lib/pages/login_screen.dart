import 'package:flutter/material.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double opacity = 0.0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoggedIn = false;
  bool isLoading = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool autoLogin = prefs.getBool('autoLogin') ?? false;

    if (autoLogin) {
      if (prefs.getString('email') != null &&
          prefs.getString('password') != null) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
        setState(() {
          isLoading = true;
        });
        signIn(prefs.getString('email') ?? '',
                prefs.getString('password') ?? '')
            .then(
          (value) {
            if (value) {
              Future.delayed(
                const Duration(seconds: 2),
                () {
                  Navigator.pushReplacementNamed(context, 'home_page');
                },
              );
            } else {
              Future.delayed(
                const Duration(seconds: 2),
                () {
                  setState(
                    () {
                      isLoading = false;
                      prefs.setBool('autoLogin', false);
                    },
                  );

                  showBanner(context, 'Incorrect login details.');
                },
              );
            }
          },
        );
      }
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

  Future<bool> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

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

    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, 'home_page');
    }

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(
                  seconds: 1,
                ),
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
                        height: 1 / 17 * height,
                      ),
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
                                hintText: 'Enter your email',
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
                                hintText: 'Enter your password',
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
                            signIn(_emailController.text,
                                    _passwordController.text)
                                .then(
                              (value) {
                                if (value) {
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    Navigator.pushReplacementNamed(
                                        context, 'home_page');
                                  });
                                } else {
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      setState(() {
                                        isLoading = false;
                                      });

                                      showBanner(
                                          context, 'Incorrect login details.');
                                    },
                                  );
                                }
                              },
                            );
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
                            horizontal:
                                isLoading ? 1 / 5 * width : 1 / 10 * width,
                            vertical: 1 / 160 * height,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                isLoading ? Colors.grey[300] : Colors.blue[200],
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
                            isLoading ? 'Loading...' : 'Login',
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
                            'Don\'t have an account?',
                            style: TextStyle(
                              fontSize: 1 / 60 * height,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, 'register_screen');
                            },
                            child: Text(
                              'Sign Up',
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
          ],
        ),
      ),
    );
  }
}
