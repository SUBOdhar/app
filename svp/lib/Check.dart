import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  List products = [];
  final mainurl = "http://192.168.0.101:5000";
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('$mainurl/products'));

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Products"),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 4.0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    title: Text(
                      product['name'],
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Expiry Date: ${product['expiry_date']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Manufacture Date: ${product['manufacture_date']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Batch No: ${product['batch_no']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Quantity: ${product['quantity']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Product Checker',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 16.0),
      ),
    ),
    home: const Check(),
  ));
}
