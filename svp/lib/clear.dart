import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Clear extends StatefulWidget {
  const Clear({super.key});

  @override
  State<Clear> createState() => _ClearState();
}

class _ClearState extends State<Clear> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Inventory Management App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, bool> _selectedData = {
    'clear_items': false,
    'clear_sales': false,
    'clear_customers': false,
    'clear_dealers': false,
  };

  Future<void> _clearData(BuildContext context) async {
    const baseUrl = 'https://api.svp.com.np';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('key') ?? '';

    // Add the key to the _selectedData map
    final requestData = {
      ..._selectedData,
      'key': key,
    };

    final clearUrl = Uri.parse('$baseUrl/clear-data');
    try {
      final response = await http.post(
        clearUrl,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data cleared successfully.'),
        ));
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to clear data.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clear Data',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'Select data to clear:',
            ),
            CheckboxListTile(
              title: const Text('Items'),
              value: _selectedData['clear_items'],
              onChanged: (bool? value) {
                setState(() {
                  _selectedData['clear_items'] = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Sales'),
              value: _selectedData['clear_sales'],
              onChanged: (bool? value) {
                setState(() {
                  _selectedData['clear_sales'] = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Customers'),
              value: _selectedData['clear_customers'],
              onChanged: (bool? value) {
                setState(() {
                  _selectedData['clear_customers'] = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Dealers'),
              value: _selectedData['clear_dealers'],
              onChanged: (bool? value) {
                setState(() {
                  _selectedData['clear_dealers'] = value!;
                });
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                textStyle: WidgetStateProperty.all<TextStyle>(
                  const TextStyle(fontSize: 16),
                ),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
                shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Confirm Clear Data',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      content:
                          const Text('Are you sure you want to clear data?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearData(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Clear Data',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
