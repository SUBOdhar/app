import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final String batchNo;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.batchNo,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      batchNo: json['batch_no'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'].toDouble(),
    );
  }
}

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({super.key});

  @override
  _SellProductScreenState createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _addressController = TextEditingController();
  final _apiUrl = 'https://api.svp.com.np';

  final _quantityfocus = FocusNode();
  final _addressfocus = FocusNode();
  final _customernamefocus = FocusNode();
  final _phonenofocus = FocusNode();

  List<Product> _products = [];
  Product? _selectedProduct;
  double _estimatedPrice = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _quantityController.addListener(_updateEstimatedPrice);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerNameController.dispose();
    _phoneNoController.dispose();
    _addressController.dispose();
    _quantityfocus.dispose();
    _addressfocus.dispose();
    _customernamefocus.dispose();
    _phonenofocus.dispose();

    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (error) {
      print('Error fetching products: $error');
      // Handle error gracefully
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
    });
  }

  Future<void> _sellProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedProduct != null) {
        // Ensure productIds and batchNo have the same length
        List<int> productIds = [_selectedProduct!.id];
        List<String> batchNo = [_selectedProduct!.batchNo];

        final payload = {
          'productIds': productIds,
          'batchNo': batchNo,
          'quantity': int.parse(_quantityController.text),
          'total_price': _estimatedPrice,
          'customerName': _customerNameController.text,
          'phoneNo': _phoneNoController.text,
          'address': _addressController.text,
        };

        final response = await http.post(
          Uri.parse('$_apiUrl/sell'),
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
    } catch (error) {
      print('Error selling product: $error');
      _showDialog('Error', 'Failed to sell product', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _products.isNotEmpty
                        ? DropdownButtonFormField<Product>(
                            value: _selectedProduct,
                            items: _products
                                .map((product) => DropdownMenuItem(
                                      value: product,
                                      child: Text(
                                          '${product.name} - ${product.batchNo}'),
                                    ))
                                .toList(),
                            onChanged: (product) {
                              setState(() {
                                _selectedProduct = product;
                                _updateEstimatedPrice(); // Update estimated price when product changes
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
                          )
                        : const SizedBox(), // Handle case where products are not fetched yet
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _quantityController,
                      focusNode: _quantityfocus,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Customer Name'),
                      controller: _customerNameController,
                      focusNode: _customernamefocus,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Phone No.'),
                      controller: _phoneNoController,
                      focusNode: _phonenofocus,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Address'),
                      controller: _addressController,
                      focusNode: _addressfocus,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
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
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
