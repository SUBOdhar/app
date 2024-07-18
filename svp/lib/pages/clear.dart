import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Clear extends StatefulWidget {
  const Clear({Key? key}) : super(key: key);

  @override
  _ClearState createState() => _ClearState();
}

class _ClearState extends State<Clear> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final Map<String, bool> _selectedData = {
    'clear_items': false,
    'clear_sales': false,
    'clear_customers': false,
    'clear_dealers': false,
  };

  bool _isLoading = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _clearData() async {
    setState(() {
      _isLoading = true;
    });

    final baseUrl = 'https://api.svp.com.np';
    final String key = _prefs.getString('key') ?? '';

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
        _showSnackBar('Data cleared successfully', Colors.green);
      } else {
        _showSnackBar('Failed to clear data', Colors.red);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('An error occurred: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildCheckbox(String title, String dataKey) {
    return CheckboxListTile(
      title: Text(title),
      value: _selectedData[dataKey],
      onChanged: (bool? value) {
        setState(() {
          _selectedData[dataKey] = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Clear Data'),
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
                                  _clearData();
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear Data'),
                  ),
                ],
              ),
            ),
    );
  }
}
