import 'package:flutter/material.dart';
import 'manage_food_screen.dart';
import 'manage_orders_screen.dart'; // ✅ Correct import

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int selectedIndex = 0;

  final screens = [
    const ManageOrdersScreen(), // ✅ Make sure this class exists
    const ManageFoodScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: Colors.deepOrange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Food'),
        ],
      ),
    );
  }
}
