import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, Key? key1});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Add(),
    );
  }
}

class Add extends StatefulWidget {
  const Add({super.key, Key? key2});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _batchNoController = TextEditingController();
  DateTime? _manufactureDate;
  DateTime? _expiryDate;
  String? _selectedDealer;
  List<String> _dealerNames = [];
  bool _isLoading = false;
  String? _resultMessage;
  IconData? _resultIcon;

  final mainUrl = "http://192.168.0.101:5000";

  @override
  void initState() {
    super.initState();
    _fetchDealerNames();
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    _batchNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchDealerNames() async {
    final url = Uri.parse('$mainUrl/dealers');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          if (data.isNotEmpty && data.first is String) {
            _dealerNames = List<String>.from(data);
          } else {
            throw Exception('Invalid response format');
          }
        });
      } else {
        throw Exception('Failed to fetch dealers: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch dealer names');
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.red[100],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isManufactureDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        if (isManufactureDate) {
          _manufactureDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _manufactureDate != null &&
        _expiryDate != null &&
        _selectedDealer != null) {
      setState(() {
        _isLoading = true;
      });
      _addItem();
    } else {
      _showErrorDialog('Please fill in all fields');
    }
  }

  Future<void> _addItem() async {
    final String item = _itemController.text;
    final int quantity = int.parse(_quantityController.text);
    final String batchNo = _batchNoController.text;
    final String manufactureDate = _manufactureDate!.toIso8601String();
    final String expiryDate = _expiryDate!.toIso8601String();

    final url = Uri.parse('$mainUrl/add-item');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item': item,
          'quantity': quantity,
          'batchNo': batchNo,
          'manufactureDate': manufactureDate,
          'expiryDate': expiryDate,
          'dealerName': _selectedDealer,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _resultMessage = 'Item added successfully';
          _resultIcon = Icons.check;
          _isLoading = false;
        });
        _itemController.clear();
        _quantityController.clear();
        _batchNoController.clear();
        setState(() {
          _manufactureDate = null;
          _expiryDate = null;
          _selectedDealer = null;
        });
        _showSuccessDialog(_resultMessage!);
      } else {
        throw Exception('Failed to add item: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Failed to add item: $e';
        _resultIcon = Icons.error;
        _isLoading = false;
      });
      _showErrorDialog(_resultMessage!);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.green[100],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    labelText: 'Item',
                    prefixIcon: Icon(Icons.shopping_bag),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.format_list_numbered),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _batchNoController,
                  decoration: const InputDecoration(
                    labelText: 'Batch No',
                    prefixIcon: Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the batch number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _selectedDealer ?? 'Select Dealer',
                    style: TextStyle(
                      color:
                          _selectedDealer == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  onTap: () {
                    _showDealerPicker();
                  },
                  leading: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _manufactureDate == null
                        ? 'Select Manufacture Date'
                        : 'Manufacture Date: ${_manufactureDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(
                      color:
                          _manufactureDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  onTap: () => _selectDate(context, true),
                  leading: const Icon(Icons.calendar_today),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _expiryDate == null
                        ? 'Select Expiry Date'
                        : 'Expiry Date: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(
                      color: _expiryDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  onTap: () => _selectDate(context, false),
                  leading: const Icon(Icons.calendar_today),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDealerPicker() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Dealer'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Set a maximum height for the dialog
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _dealerNames.length,
                    itemBuilder: (BuildContext context, int index) {
                      final dealer = _dealerNames[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            dealer,
                            style: const TextStyle(color: Colors.blue),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedDealer = dealer;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
