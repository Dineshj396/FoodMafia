import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;

  PaymentPage({required this.totalAmount});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = 'card';
  bool isProcessing = false;

  Future<void> processPayment() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppState().apiUrl}/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': AppState().userEmail,
          'payment_method': selectedPayment,
        }),
      );

      if (response.statusCode == 200) {
        // Clear the cart
        AppState().cart = [];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful!')),
        );

        // Return to the menu page
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        final error = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Payment failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount to Pay:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(
                '₹${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 24),
            Text('Payment Method', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),

            RadioListTile<String>(
              title: Row(
                children: [
                  Icon(Icons.credit_card),
                  SizedBox(width: 16),
                  Text('Credit/Debit Card'),
                ],
              ),
              value: 'card',
              groupValue: selectedPayment,
              onChanged: (value) {
                setState(() {
                  selectedPayment = value!;
                });
              },
            ),

            RadioListTile<String>(
              title: Row(
                children: [
                  Icon(Icons.account_balance_wallet),
                  SizedBox(width: 16),
                  Text('UPI / Wallet'),
                ],
              ),
              value: 'upi',
              groupValue: selectedPayment,
              onChanged: (value) {
                setState(() {
                  selectedPayment = value!;
                });
              },
            ),

            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: isProcessing ? null : processPayment,
                child: isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Pay Now', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}