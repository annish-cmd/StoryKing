/*
 * CONTACT SCREEN
 * ------------
 * Displays contact information for the app team.
 * 
 * Key features:
 * - Phone numbers for direct contact
 * - Team member contact information
 * - Office contact details
 * 
 * UI elements:
 * - Gradient background
 * - Contact cards with visual styling
 * - Icons for phone and person
 * - Clean, readable layout for information
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6448FE),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6448FE),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get in Touch',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Phone Numbers:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildContactContainer('1234567890', 'E-NET Pvt.Ltd.'),
              const SizedBox(height: 10),
              _buildContactContainer('1234567891', 'Shiwan Shrestha'),
              const SizedBox(height: 10),
              _buildContactContainer('1234567892', 'Anish Chauhan'),
              const SizedBox(height: 10),
              _buildContactContainer('1234567893', 'Krish Lama'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactContainer(String phoneNumber, String name) {
    return Card(
      color: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFA07A), // Pinkish color
              Color(0xFF5FC6FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  phoneNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
