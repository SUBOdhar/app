import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Add(),
    );
  }
}

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);

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
    final url = Uri.parse('http://192.168.101.3:5000/dealers');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          if (data.isNotEmpty && data.first is String) {
            _dealerNames = [data.first as String];
          } else {
            throw Exception('Invalid response format');
          }
        });
      } else {
        throw Exception('Failed to fetch dealers: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to fetch dealer names');
    }
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _manufactureDate != null &&
        _expiryDate != null &&
        _selectedDealer != null) {
      setState(() {
        _isLoading = true;
      });
      final String item = _itemController.text;
      final int quantity = int.parse(_quantityController.text);
      final String batchNo = _batchNoController.text;
      final String manufactureDate = _manufactureDate!.toIso8601String();
      final String expiryDate = _expiryDate!.toIso8601String();

      final url = Uri.parse('http://192.168.101.3:5000/add-item');
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
        } else {
          throw Exception('Failed to add item: ${response.body}');
        }
      } catch (e) {
        setState(() {
          _resultMessage = 'Failed to add item: $e';
          _resultIcon = Icons.error;
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Colors.blue),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Add items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _itemController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Item',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Quantity',
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
                SizedBox(height: 16),
                TextFormField(
                  controller: _batchNoController,
                  decoration: inputDecoration.copyWith(
                    labelText: 'Batch No',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the batch number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: DropdownButtonFormField<String>(
                    value: _selectedDealer,
                    items: _dealerNames.map((String dealer) {
                      return DropdownMenuItem<String>(
                        value: dealer,
                        child: Text(
                          dealer,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedDealer = value;
                      });
                    },
                    decoration: inputDecoration.copyWith(
                      labelText: 'Select Dealer',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 32,
                    iconEnabledColor: Colors.blue,
                    dropdownColor: Colors.white,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _manufactureDate == null
                        ? 'Select Manufacture Date'
                        : 'Manufacture Date: ${_manufactureDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(
                      color:
                          _manufactureDate == null ? Colors.red : Colors.black,
                    ),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _expiryDate == null
                        ? 'Select Expiry Date'
                        : 'Expiry Date: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(
                      color: _expiryDate == null ? Colors.red : Colors.black,
                    ),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_resultMessage != null)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _resultMessage!.contains('successfully')
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _resultIcon,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _resultMessage!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
