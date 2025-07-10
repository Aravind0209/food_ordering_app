import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/order.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final firestore = FirestoreService();
  final List<String> statusOptions = ['Pending', 'In Progress', 'Completed'];

  // Confirm and delete one order
  void _confirmDelete(String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Order"),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await firestore.deleteOrder(orderId);
              setState(() {});
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Confirm and clear all orders
  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear All Orders"),
        content: const Text("This will permanently remove all orders from the admin side. Continue?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await firestore.clearAllOrders();
              setState(() {});
            },
            child: const Text("Clear All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear All Orders",
            onPressed: _confirmClearAll,
          )
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: firestore.getAllOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text("No orders yet."));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final currentStatus = order.status ?? 'Pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User: ${order.userName ?? order.userId}", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Items: ${order.items.map((e) => e['name']).join(', ')}"),
                      Text("Total: RM${order.total.toStringAsFixed(2)}"),
                      Text("Method: ${order.paymentMethod}"),
                      Text("Date: ${order.timestamp.toLocal().toString().substring(0, 16)}"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: currentStatus,
                            items: statusOptions.map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (newStatus) async {
                              if (newStatus != null) {
                                await firestore.updateOrderStatus(order.id, newStatus);
                                setState(() {});
                              }
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(order.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
