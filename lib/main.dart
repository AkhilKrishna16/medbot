import 'package:flutter/material.dart';

import './pages/intro_screen.dart';
import './pages/login_screen.dart';
import './pages/home_page.dart';
import './pages/register_screen.dart';

import 'package:firebase_core/firebase_core.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MedBot());
}

class MedBot extends StatefulWidget {
  const MedBot({super.key});

  @override
  State<MedBot> createState() => MedBotState();
}

class MedBotState extends State<MedBot> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'intro_screen',
      routes: {
        'intro_screen': (context) => const IntroScreen(),
        'login_screen': (context) => const LoginScreen(),
        'home_page': (context) => const HomePage(),
        'register_screen': (context) => const RegisterScreen(),
      },
    );
  }
}
