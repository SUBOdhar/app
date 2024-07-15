import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Clear extends StatefulWidget {
  const Clear({Key? key}) : super(key: key);

  @override
  _ClearState createState() => _ClearState();
}

class _ClearState extends State<Clear> {
  final Map<String, bool> _selectedData = {
    'clear_items': false,
    'clear_sales': false,
    'clear_customers': false,
    'clear_dealers': false,
  };

  bool _isLoading = false;

  Future<void> _clearData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    const baseUrl = 'https://api.svp.com.np';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('key') ?? '';

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
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data cleared successfully.'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to clear data.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget _buildCheckbox(String title, String key) {
    return CheckboxListTile(
      title: Text(title),
      value: _selectedData[key],
      onChanged: (bool? value) {
        setState(() {
          _selectedData[key] = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clear Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20.0),
                  const Text(
                    'Select data to clear:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildCheckbox('Items', 'clear_items'),
                  _buildCheckbox('Sales', 'clear_sales'),
                  _buildCheckbox('Customers', 'clear_customers'),
                  _buildCheckbox('Dealers', 'clear_dealers'),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.green),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
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
                            content: const Text(
                                'Are you sure you want to clear data?'),
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
                    child: const Text('Clear Data'),
                  ),
                ],
              ),
            ),
    );
  }
}
