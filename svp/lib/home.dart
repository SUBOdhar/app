import 'package:flutter/material.dart';

class VeterinaryDashboard extends StatelessWidget {
  const VeterinaryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veterinary Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinary Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSectionHeader('Appointments'),
            _buildAppointmentsList(),
            _buildSectionHeader('Patient Records'),
            _buildPatientRecordsList(),
            _buildSectionHeader('Inventory Management'),
            _buildInventoryManagement(),
            // Add more sections as needed
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    // Placeholder for appointments list
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Appointments List'),
      ),
    );
  }

  Widget _buildPatientRecordsList() {
    // Placeholder for patient records list
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Patient Records List'),
      ),
    );
  }

  Widget _buildInventoryManagement() {
    // Placeholder for inventory management
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text('Inventory Management'),
      ),
    );
  }
}
