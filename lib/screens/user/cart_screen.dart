import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<bool> selectedItems;
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartService>(context, listen: false);
    selectedItems = List<bool>.filled(cart.items.length, false);
  }

  double calculateSelectedTotal(CartService cart) {
    double total = 0;
    for (int i = 0; i < cart.items.length; i++) {
      if (selectedItems[i]) {
        final item = cart.items[i];
        total += item['item'].price * item['qty'];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    // Keep selection list in sync with cart length
    if (selectedItems.length != cart.items.length) {
      selectedItems = List<bool>.filled(cart.items.length, false);
      selectAll = false;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Checkbox(
                            value: selectedItems[index],
                            onChanged: (val) {
                              setState(() {
                                selectedItems[index] = val!;
                                selectAll = selectedItems.every((e) => e);
                              });
                            },
                          ),
                          title: Row(
                            children: [
                              Image.network(item['item'].imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['item'].name,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('RM${item['item'].price.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  final qty = item['qty'] - 1;
                                  if (qty <= 0) {
                                    cart.removeFromCart(item['item']);
                                  } else {
                                    cart.updateQty(item['item'], qty);
                                  }
                                },
                              ),
                              Text('${item['qty']}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => cart.updateQty(item['item'], item['qty'] + 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cart.removeFromCart(item['item']);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Total + Checkout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, -1),
                    )
                  ]),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectAll,
                        onChanged: (val) {
                          setState(() {
                            selectAll = val!;
                            selectedItems = List<bool>.filled(cart.items.length, selectAll);
                          });
                        },
                      ),
                      const Text("All"),
                      const Spacer(),
                      Text(
                        "RM${calculateSelectedTotal(cart).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: selectedItems.contains(true)
                            ? () {
                                final selected = cart.items
                                    .asMap()
                                    .entries
                                    .where((entry) => selectedItems[entry.key])
                                    .map((entry) => entry.value)
                                    .toList();

                                // You can pass selected to PaymentScreen if needed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                                );
                              }
                            : null,
                        child: Text("Check Out (${selectedItems.where((e) => e).length})"),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
