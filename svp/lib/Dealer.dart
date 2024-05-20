import 'package:flutter/material.dart';

class Dealer extends StatefulWidget {
  const Dealer({super.key});

  @override
  State<Dealer> createState() => _DealerState();
}

class _DealerState extends State<Dealer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Dealer"),
      ),
    );
  }
}
