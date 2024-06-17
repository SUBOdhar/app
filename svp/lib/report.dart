import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReportDataApp extends StatefulWidget {
  const ReportDataApp({super.key});

  @override
  State<ReportDataApp> createState() => _ReportDataAppState();
}

class _ReportDataAppState extends State<ReportDataApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Report App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Report(),
    );
  }
}

class ProductTransaction {
  final String item;
  final int quantity;
  final String date;
  final double? totalPrice;
  final String? dealerName;
  final String? customerName;

  ProductTransaction({
    required this.item,
    required this.quantity,
    required this.date,
    this.totalPrice,
    this.dealerName,
    this.customerName,
  });

  factory ProductTransaction.fromJson(Map<String, dynamic> json) {
    return ProductTransaction(
      item: json['item'],
      quantity: json['quantity'],
      date: json['date'] ?? '',
      totalPrice: json['totalPrice']?.toDouble(),
      dealerName: json['dealerName'],
      customerName: json['customerName'],
    );
  }
}

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  late Future<Map<String, List<ProductTransaction>>> _dailyReport;
  final String _reportDate = DateTime.now().toIso8601String().split('T').first;
  String? _dealerName;
  String? _customerName;
  String? _startDate;
  String? _endDate;

  final List<String> _dealers = [];
  final List<String> _customers = [];

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _dailyReport = fetchDailyReport(_reportDate);
    fetchDealersAndCustomers();
  }

  Future<void> fetchDealersAndCustomers() async {
    await fetchOptions('/dealers', _dealers);
    await fetchOptions('/customers', _customers);
  }

  Future<void> fetchOptions(String endpoint, List<String> targetList) async {
    final response =
        await http.get(Uri.parse('https://api.svp.com.np$endpoint'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      targetList.addAll(data.cast<String>());
    } else {
      throw Exception('Failed to fetch $endpoint');
    }
  }

  void _applyFilters() {
    setState(() {
      _dailyReport = fetchDailyReport(_reportDate,
          dealerName: _dealerName,
          customerName: _customerName,
          startDate: _startDate,
          endDate: _endDate);
      _showFilters = false;
    });
  }

  Future<Map<String, List<ProductTransaction>>> fetchDailyReport(String date,
      {String? dealerName,
      String? customerName,
      String? startDate,
      String? endDate}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('key') ?? '';

    String apiUrl = 'https://api.svp.com.np/daily-report?date=$date&key=$key';

    if (dealerName != null) {
      apiUrl += '&dealer_name=$dealerName';
    }
    if (customerName != null) {
      apiUrl += '&customer_name=$customerName';
    }
    if (startDate != null) {
      apiUrl += '&start_date=$startDate';
    }
    if (endDate != null) {
      apiUrl += '&end_date=$endDate';
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      List<ProductTransaction> addedProducts = (data['added_products'] as List)
          .map((item) => ProductTransaction.fromJson(item))
          .toList();

      List<ProductTransaction> soldProducts = (data['sold_products'] as List)
          .map((item) => ProductTransaction.fromJson(item))
          .toList();

      return {
        'added': addedProducts,
        'sold': soldProducts,
      };
    } else {
      throw Exception('Failed to load daily report');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked.toIso8601String().split('T').first;
        } else {
          _endDate = picked.toIso8601String().split('T').first;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _dealerName = null;
      _customerName = null;
      _startDate = null;
      _endDate = null;
      _showFilters = false;
      _dailyReport = fetchDailyReport(_reportDate);
    });
  }

  void _selectDealerOrCustomer(bool isDealer) {
    List<String> options = isDealer ? _dealers : _customers;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isDealer ? 'Select Dealer' : 'Select Customer'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              children: options.map((option) {
                return FilterChip(
                  label: Text(option),
                  selected: isDealer
                      ? _dealerName == option
                      : _customerName == option,
                  onSelected: (selected) {
                    setState(() {
                      if (isDealer) {
                        _dealerName = selected ? option : null;
                      } else {
                        _customerName = selected ? option : null;
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Report"),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.close : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      FilterChip(
                        label: Text(_dealerName ?? 'Select Dealer'),
                        onSelected: (_) {
                          _selectDealerOrCustomer(true);
                        },
                      ),
                      FilterChip(
                        label: Text(_customerName ?? 'Select Customer'),
                        onSelected: (_) {
                          _selectDealerOrCustomer(false);
                        },
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(_startDate == null
                            ? 'Select Start Date'
                            : 'Start Date                            Date: $_startDate'),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(_endDate == null
                            ? 'Select End Date'
                            : 'End Date: $_endDate'),
                      ),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                      ElevatedButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, List<ProductTransaction>>>(
              future: _dailyReport,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                } else {
                  final addedProducts = snapshot.data!['added']!;
                  final soldProducts = snapshot.data!['sold']!;
                  return ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Added Products',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...addedProducts.map((product) => _buildProductCard(
                          product.item,
                          'Quantity: ${product.quantity}\nAdded Date: ${product.date}\nDealer: ${product.dealerName}',
                          context)),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Sold Products',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...soldProducts.map((product) => _buildProductCard(
                          product.item,
                          'Quantity: ${product.quantity}\nSold Date: ${product.date}\nCustomer: ${product.customerName}\nTotal Price: ${product.totalPrice}',
                          context)),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      String title, String subtitle, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
