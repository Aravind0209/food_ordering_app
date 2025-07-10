import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/food_card.dart';
import '../../services/cart_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedTab = 'All';
  String search = '';
  final firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context, listen: false);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => search = val),
              decoration: InputDecoration(
                hintText: 'Search food or drink...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['All', 'Food', 'Drink'].map((e) {
                return ChoiceChip(
                  label: Text(e),
                  selected: selectedTab == e,
                  onSelected: (_) => setState(() => selectedTab = e),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<FoodItem>>(
              future: firestore.getMenuItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                List<FoodItem> items = snapshot.data!;
                if (selectedTab != 'All') {
                  items = items.where((i) => i.category == selectedTab.toLowerCase()).toList();
                }
                if (search.isNotEmpty) {
                  items = items.where((i) => i.name.toLowerCase().contains(search.toLowerCase())).toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return FoodCard(
                      item: items[index],
                      onTap: () {
                        cart.addToCart(items[index]);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to cart")));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
