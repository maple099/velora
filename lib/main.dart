import 'package:flutter/material.dart';
import 'screens/auth/splash_page.dart';

void main() {
  runApp(const VeloraApp());
}

class VeloraApp extends StatelessWidget {
  const VeloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Velora',
      theme: ThemeData(fontFamily: 'Poppins', primarySwatch: Colors.deepPurple),
      home: const SplashPage(),
    );
  }
}
