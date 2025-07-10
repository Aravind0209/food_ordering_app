import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/cart_service.dart';
import '../../models/order.dart' as my_order;
import '../../services/firestore_service.dart';
import 'order_summary_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select Payment Method:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _placeOrder(context, cart, 'Pay Counter'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text('Pay At Counter'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _placeOrder(context, cart, 'FPX'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text('Pay with FPX (Dummy)'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, CartService cart, String method) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ✅ Fetch user name from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userName = userDoc.data()?['name'] ?? 'Unknown';

    final orderData = my_order.Order(
      id: '',
      userId: user.uid,
      userName: userName, // ✅ new field
      items: cart.items.map((e) => {
        'id': e['item'].id,
        'name': e['item'].name,
        'price': e['item'].price,
        'qty': e['qty'],
      }).toList(),
      total: cart.total,
      paymentMethod: method,
      timestamp: DateTime.now(),
    );

    // Save order and get generated ID
    final docRef = await FirebaseFirestore.instance.collection('orders').add(orderData.toMap());

    final fullOrder = my_order.Order(
      id: docRef.id,
      userId: orderData.userId,
      userName: orderData.userName,
      items: orderData.items,
      total: orderData.total,
      paymentMethod: orderData.paymentMethod,
      timestamp: orderData.timestamp,
    );

    cart.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderSummaryScreen(order: fullOrder)),
    );
  }
}
