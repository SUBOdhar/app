import 'package:flutter/material.dart';

class VeterinaryDashboard extends StatelessWidget {
  const VeterinaryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome subodh'),
          leading: Container(
            margin: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/clock.png'), // Replace with your image URL
            ),
          ),
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

void main() {
  runApp(const VeterinaryDashboard());
}
