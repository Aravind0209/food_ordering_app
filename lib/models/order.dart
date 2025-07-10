import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String? userName; // ✅ Added field
  final List<Map<String, dynamic>> items;
  final double total;
  final String paymentMethod;
  final DateTime timestamp;
  final String? status;

  Order({
    required this.id,
    required this.userId,
    this.userName, // ✅ Constructor updated
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.timestamp,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName, // ✅ Save user name
      'items': items,
      'total': total,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
      'status': status ?? 'Pending',
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'], // ✅ Read user name
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'Unknown',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Pending',
    );
  }
}
