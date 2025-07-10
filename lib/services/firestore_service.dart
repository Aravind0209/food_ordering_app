import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../models/order.dart' as my_order;

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Fetch all food items
  Future<List<FoodItem>> getMenuItems() async {
    final snapshot = await _db.collection('food_items').get();
    return snapshot.docs
        .map((doc) => FoodItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Add new food item
  Future<void> addFoodItem(FoodItem item) async {
    await _db.collection('food_items').add(item.toMap());
  }

  // Update existing food item
  Future<void> updateFoodItem(FoodItem item) async {
    await _db.collection('food_items').doc(item.id).update(item.toMap());
  }

  // Delete food item
  Future<void> deleteFoodItem(String id) async {
    await _db.collection('food_items').doc(id).delete();
  }

  // ✅ Place an order with default status and user name
  Future<void> placeOrder(my_order.Order order) async {
    final user = FirebaseAuth.instance.currentUser;

    String userName = 'Unknown';
    if (user != null) {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      userName = userDoc.data()?['name'] ?? 'Unknown';
    }

    final data = order.toMap();
    data['status'] = order.status ?? 'Pending';
    data['userName'] = order.userName ?? 'Unknown';

    await _db.collection('orders').add(data);
  }

  // Get all orders
  Future<List<my_order.Order>> getAllOrders() async {
    final snapshot = await _db.collection('orders').get();
    return snapshot.docs
        .map((doc) => my_order.Order.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Update the status of a specific order
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  // Delete a single order (admin)
  Future<void> deleteOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).delete();
  }

  // Clear all orders (admin action)
  Future<void> clearAllOrders() async {
    final snapshot = await _db.collection('orders').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Fetch all users (for admin panel)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}

