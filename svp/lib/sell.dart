import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class Sell extends StatefulWidget {
  const Sell({super.key});

  @override
  State<Sell> createState() => _SellState();
}

class _SellState extends State<Sell> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sell Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
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

  final FocusNode _quantityFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _customerNameFocus = FocusNode();
  final FocusNode _phoneNoFocus = FocusNode();

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
    _quantityFocus.dispose();
    _addressFocus.dispose();
    _customerNameFocus.dispose();
    _phoneNoFocus.dispose();

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
      _showErrorDialog('Failed to fetch products: $error');
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
          _showSuccessDialog('Success', responseJson['message']);
        } else {
          _showErrorDialog(responseJson['message']);
        }
      }
    } catch (error) {
      _showErrorDialog('Failed to sell product: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _showSuccessDialog(String title, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
        title: const Text('Sell Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  _updateEstimatedPrice();
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Product',
                                hintText: 'Select product',
                                prefixIcon: Icon(Icons.medication_outlined),
                              ),
                              validator: (value) {
                                if (_selectedProduct == null) {
                                  return 'Please select a product';
                                }
                                return null;
                              },
                            )
                          : const SizedBox(),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _quantityController,
                        focusNode: _quantityFocus,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: Icon(Icons.shopping_cart),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        controller: _customerNameController,
                        focusNode: _customerNameFocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone No.',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        controller: _phoneNoController,
                        focusNode: _phoneNoFocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        controller: _addressController,
                        focusNode: _addressFocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ListTile(
                        title: Text(
                          'Estimated Price: $_estimatedPrice',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        leading: const Icon(Icons.attach_money),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _sellProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Sell Product'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
