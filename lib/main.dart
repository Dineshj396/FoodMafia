// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'CartPage.dart';
import 'LoginPage.dart';
import 'MenuPage.dart';
import 'OrdersPage.dart';
import 'SignUpPage.dart';

void main() => runApp(MyApp());

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String? userEmail;
  List<Map<String, dynamic>> cart = [];

  // Base URL for the API
  final String apiUrl = 'http://127.0.0.1:5000/api'; // Use this for Android emulator
// final String apiUrl = 'http://localhost:5000/api'; // Use this for iOS simulator
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FC CORNER',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/menu': (context) => MenuPage(),
      },
    );
  }
}

// LoginPage.dart

// SignUpPage.dart

// MenuPage.dart

// CartPage.dart

// PaymentPage.dart

// Let's also add an OrdersPage to view past orders

