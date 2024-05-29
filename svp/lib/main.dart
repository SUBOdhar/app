import 'package:flutter/material.dart';
import 'package:svp/Check.dart';
import 'package:svp/Dealer.dart';
import 'package:svp/add_product.dart';
import 'package:svp/clear.dart';
import 'package:svp/login.dart';
import 'package:svp/report.dart';
import 'package:svp/sell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/add-item': (context) => const Add(),
        '/dealers': (context) => const Dealer(),
        '/products': (context) => const Check(),
        '/sell': (context) => const Sell(),
        '/report': (context) => const Report(),
        '/clear': (context) => const Clear()
      },
    );
  }
}
