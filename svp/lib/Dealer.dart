import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class Dealer extends StatefulWidget {
  const Dealer({super.key});

  @override
  State<Dealer> createState() => _DealerState();
}

class _DealerState extends State<Dealer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _panController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://192.168.0.103:5000/add-dealer');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': _nameController.text,
          'address': _addressController.text,
          'phoneNo': _phoneNoController.text,
          'email': _emailController.text,
          'panno': _panController.text,
        }),
      );

      IconData iconData;
      String message;
      String title;

      if (response.statusCode == 200) {
        iconData = Icons.check_circle;
        title = 'Success';
        message = 'Dealer added successfully';
        _nameController.clear();
        _addressController.clear();
        _phoneNoController.clear();
        _emailController.clear();
        _panController.clear();
      } else {
        iconData = Icons.error;
        title = 'Error';
        message = 'Failed to add dealer';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(iconData),
                const SizedBox(width: 10),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: const OutlineInputBorder(),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
      ),
      prefixIconColor: Theme.of(context).primaryColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Dealer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Name',
                    prefixIcon: const Icon(Symbols.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Address',
                    prefixIcon: const Icon(Symbols.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNoController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Symbols.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Email',
                    prefixIcon: const Icon(Symbols.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _panController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Pan no',
                    prefixIcon: const Icon(Symbols.id_card),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the pan no';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add Dealer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const Dealer(),
    theme: ThemeData(
      primaryColor: Colors.purple,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
