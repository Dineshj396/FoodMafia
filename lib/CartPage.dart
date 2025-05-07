import 'package:flutter/material.dart';
import ' PaymentPage.dart';

import 'main.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double calculateTotalPrice() {
    double total = 0;
    for (var item in AppState().cart) {
      total += (item['quantity'] ?? 0) * (item['price'] ?? 0);
    }
    return total;
  }

  void handleCheckout() {
    if (AppState().cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(totalAmount: calculateTotalPrice()),
      ),
    );
  }

  void removeItem(int index) {
    setState(() {
      final removedItem = AppState().cart.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${removedItem['name']} removed from cart')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: AppState().cart.isEmpty
          ? Center(child: Text('No items in the cart'))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: AppState().cart.length,
        itemBuilder: (context, index) {
          final item = AppState().cart[index];
          final quantity = item['quantity'] ?? 0;
          final price = item['price'] ?? 0;
          final total = price * quantity;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['image'], style: TextStyle(fontSize: 30)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('₹$price each'),
                        Text('Total: ₹$total'),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text('x$quantity'),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppState().cart.isNotEmpty
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ₹${calculateTotalPrice().toStringAsFixed(2)}',
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: handleCheckout,
                icon: Icon(Icons.payment, color: Colors.white),
                label: Text('Checkout',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }
}
