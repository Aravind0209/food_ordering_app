import 'package:flutter/material.dart';
import '../models/food_item.dart';

class CartService extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  final Set<String> _selectedItemIds = {}; // Track selected items

  List<Map<String, dynamic>> get items => _items;

  void addToCart(FoodItem item) {
    final index = _items.indexWhere((e) => e['item'].id == item.id);
    if (index == -1) {
      _items.add({'item': item, 'qty': 1});
    } else {
      _items[index]['qty'] += 1;
    }
    _selectedItemIds.add(item.id); // Auto-select on add
    notifyListeners();
  }

  void removeFromCart(FoodItem item) {
    _items.removeWhere((e) => e['item'].id == item.id);
    _selectedItemIds.remove(item.id); // Unselect if removed
    notifyListeners();
  }

  void updateQty(FoodItem item, int qty) {
    final index = _items.indexWhere((e) => e['item'].id == item.id);
    if (index != -1) {
      _items[index]['qty'] = qty;
      notifyListeners();
    }
  }

  double get total {
    return _items.fold(0.0, (sum, e) {
      return sum + (e['item'].price * e['qty']);
    });
  }

  void clear() {
    _items.clear();
    _selectedItemIds.clear();
    notifyListeners();
  }

  // === Selection Logic ===
  bool isSelected(String itemId) => _selectedItemIds.contains(itemId);

  void toggleSelection(String itemId) {
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedItemIds.addAll(_items.map((e) => e['item'].id));
    notifyListeners();
  }

  void deselectAll() {
    _selectedItemIds.clear();
    notifyListeners();
  }

  bool get isAllSelected => _selectedItemIds.length == _items.length;

  List<Map<String, dynamic>> get selectedItems =>
      _items.where((e) => _selectedItemIds.contains(e['item'].id)).toList();

  double get selectedTotal {
    return selectedItems.fold(0.0, (sum, e) {
      return sum + (e['item'].price * e['qty']);
    });
  }
}
