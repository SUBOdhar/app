import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Sell());
}

class Sell extends StatelessWidget {
  const Sell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sell Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.blueAccent),
        ),
      ),
      home: const SellProductScreen(),
    );
  }
}

class Product {
  final int id;
  final String name;
  final List<Batch> batches;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.batches,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      batches: json['batches'] != null
          ? (json['batches'] as List<dynamic>)
              .map((batchJson) => Batch.fromJson(batchJson))
              .toList()
          : [],
      price: json['price'].toDouble(),
    );
  }
}

class Batch {
  final String batchNo;
  final String expiryDate;

  Batch({
    required this.batchNo,
    required this.expiryDate,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      batchNo: json['batch_no'],
      expiryDate: json['expiry_date'],
    );
  }
}

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({super.key});

  @override
  _SellProductScreenState createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final String apiUrl = 'http://192.168.0.101:5000/products';

  List<Product> _products = [];
  Product? _selectedProduct;
  Batch? _selectedBatch;
  double _estimatedPrice = 0.0;

  late FocusNode _quantityFocusNode;
  late FocusNode _totalPriceFocusNode;
  late FocusNode _customerNameFocusNode;
  late FocusNode _phoneNoFocusNode;
  late FocusNode _addressFocusNode;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _quantityController.addListener(_updateEstimatedPrice);
    _totalPriceController.text = '0.0'; // Initialize with 0.0

    _quantityFocusNode = FocusNode();
    _totalPriceFocusNode = FocusNode();
    _customerNameFocusNode = FocusNode();
    _phoneNoFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _quantityController.removeListener(_updateEstimatedPrice);
    _quantityController.dispose();
    _totalPriceController.dispose();
    _customerNameController.dispose();
    _phoneNoController.dispose();
    _addressController.dispose();
    _quantityFocusNode.dispose();
    _totalPriceFocusNode.dispose();
    _customerNameFocusNode.dispose();
    _phoneNoFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(
          'Parsed Products Data: ${data.map((json) => Product.fromJson(json)).toList()}');
      setState(() {
        _products = data.map((json) => Product.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  void _updateEstimatedPrice() {
    double totalPrice = 0.0;
    int quantity = int.tryParse(_quantityController.text) ?? 0;

    if (_selectedProduct != null) {
      totalPrice = _selectedProduct!.price * quantity;
    }

    setState(() {
      _estimatedPrice = totalPrice;
      _totalPriceController.text =
          totalPrice.toStringAsFixed(2); // Update total price field
    });
  }

  Future<void> _sellProduct() async {
    const String apiUrl = 'http://192.168.0.101:5000/sell';

    final Map<String, dynamic> payload = {
      'productId': _selectedProduct!.id,
      'batchNo': _selectedBatch!.batchNo,
      'quantity': int.parse(_quantityController.text),
      'total_price': double.parse(_totalPriceController
          .text), // Use the manually adjustable total price
      'customerName': _customerNameController.text,
      'phoneNo': _phoneNoController.text,
      'address': _addressController.text,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    final responseJson = json.decode(response.body);

    if (response.statusCode == 200) {
      _showDialog('Success', responseJson['message'], Colors.green);
    } else {
      _showDialog('Error', responseJson['message'], Colors.red);
    }
  }

  void _showDialog(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: color,
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                items: _products
                    .map((product) => DropdownMenuItem(
                          value: product,
                          child: Text(product.name),
                        ))
                    .toList(),
                onChanged: (product) {
                  setState(() {
                    _selectedProduct = product!;
                    _selectedBatch = null;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Product',
                  hintText: 'Select product',
                ),
                validator: (value) {
                  if (_selectedProduct == null) {
                    return 'Please select a product';
                  }
                  return null;
                },
              ),
              if (_selectedProduct != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Select Batch Number',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    ..._selectedProduct!.batches.map((batch) {
                      return RadioListTile<Batch>(
                        title: Text(
                          '${batch.batchNo} (Expiry: ${batch.expiryDate})',
                        ),
                        value: batch,
                        groupValue: null, // Adjust as needed
                        onChanged: (Batch? newValue) {
                          setState(() {
                            _selectedBatch = newValue!;
                          });
                        },
                      );
                    }),
                  ],
                ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_totalPriceFocusNode);
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _totalPriceController,
                decoration: const InputDecoration(labelText: 'Total Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total price';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_customerNameFocusNode);
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_phoneNoFocusNode);
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNoController,
                decoration: const InputDecoration(labelText: 'Phone No.'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_addressFocusNode);
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (_formKey.currentState!.validate()) {
                    _sellProduct();
                  }
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sellProduct();
                  }
                },
                child: const Text('Sell Product'),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Estimated Price: $_estimatedPrice',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
