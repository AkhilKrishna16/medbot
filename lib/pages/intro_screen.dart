import 'package:flutter/material.dart';
import 'package:medbot/pages/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 1, milliseconds: 500),
      () {
        setState(
          () {
            opacity = 0.0;
          },
        );

        Future.delayed(
          const Duration(seconds: 2, milliseconds: 250),
          () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) {
                  return const LoginScreen();
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(seconds: 2),
          child: Image.asset('assets/images/MedBot.png', height: 500),
        ),
      ),
    );
  }
}
