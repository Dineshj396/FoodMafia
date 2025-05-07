import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'CartPage.dart';
import 'main.dart';


class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> foodItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    try {
      final response = await http.get(
        Uri.parse('${AppState().apiUrl}/menu'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          foodItems = List<Map<String, dynamic>>.from(data['menu']);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load menu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }
  Future<void> addToCart(Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse('${AppState().apiUrl}/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': AppState().userEmail,
          'item_id': item['id'],
          'quantity': 1, // Ensure it's a valid number for quantity
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          AppState().cart = List<Map<String, dynamic>>.from(data['cart']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item['name']} added to cart')),
        );
      } else {
        final error = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to add item to cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }



  Future<void> removeFromCart(String id) async {
    try {
      final response = await http.post(
        Uri.parse('${AppState().apiUrl}/cart/remove'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': AppState().userEmail,
          'item_id': id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          AppState().cart = List<Map<String, dynamic>>.from(data['cart']);
        });
      } else {
        final error = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to remove item from cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }
  int getItemQuantity(String id) {
    final item = AppState().cart.firstWhere(
          (item) => item['id'] == id,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Account Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${AppState().userEmail ?? "Unknown"}'),
                      SizedBox(height: 10),
                      // You can add more user details here in the future
                      Text('Status: Logged In'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              AppState().userEmail = null;
              AppState().cart = [];
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],

      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final item = foodItems[index];
          final quantity = getItemQuantity(item['id']);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Text(item['image'], style: TextStyle(fontSize: 30)),
              title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${item['price']}'),
                  Row(
                    children: List.generate(5, (i) {
                      double rating = item['rating'];
                      return Icon(
                        i < rating
                            ? Icons.star
                            : (i < rating + 0.5 ? Icons.star_half : Icons.star_border),
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: quantity > 0 ? () => removeFromCart(item['id']) : null,
                  ),
                  Text(
                    '$quantity',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.deepPurple),
                    onPressed: () => addToCart(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(),
              ),
            );
          },
          icon: Icon(Icons.shopping_cart, color: Colors.white),
          label: Text(
            'View Cart (${AppState().cart.length} items)',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
