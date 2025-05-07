import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'CartPage.dart';
import 'main.dart';




class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${AppState().apiUrl}/orders?email=${AppState().userEmail}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orders = List<Map<String, dynamic>>.from(data['orders']);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load orders')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text('No orders yet'))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final items = List<Map<String, dynamic>>.from(order['items']);
          final date = DateTime.parse(order['created_at']).toLocal();
          final formattedDate =
              '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
            child: ExpansionTile(
              title: Text(
                'Order #${order['id'].toString().substring(0, 8)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${order['total'].toStringAsFixed(2)}'),
                  Text(formattedDate),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Items:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '${item['name']} x ${item['quantity']} - ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        ),
                      )).toList(),
                      SizedBox(height: 8),
                      Text('Payment Method: ${order['payment_method']}'),
                      Text('Status: ${order['status']}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MenuPage1 extends StatefulWidget {
  @override
  _MenuPageStateV2 createState() => _MenuPageStateV2();
}

// Update MenuPage to include a drawer with access to OrdersPage
class _MenuPageStateV2 extends State<MenuPage1> {
  List<Map<String, dynamic>> foodItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenu();
    fetchCart(); // Added method to fetch the cart
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

  // Add fetchCart method to load the cart when the page loads
  Future<void> fetchCart() async {
    if (AppState().userEmail == null) return;

    try {
      final response = await http.get(
        Uri.parse('${AppState().apiUrl}/cart?email=${AppState().userEmail}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          AppState().cart = List<Map<String, dynamic>>.from(data['cart']);
        });
      }
    } catch (e) {
      // Silently handle error
      print('Error fetching cart: $e');
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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FC CORNER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppState().userEmail ?? '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Menu'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('My Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                AppState().userEmail = null;
                AppState().cart = [];
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
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