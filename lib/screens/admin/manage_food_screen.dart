import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/food_item.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFoodScreen extends StatefulWidget {
  const ManageFoodScreen({super.key});

  @override
  State<ManageFoodScreen> createState() => _ManageFoodScreenState();
}

class _ManageFoodScreenState extends State<ManageFoodScreen> {
  final firestore = FirestoreService();
  final storage = StorageService();
  final picker = ImagePicker();
  File? selectedImage;

  void showFoodForm({FoodItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    String category = item?.category ?? 'food';
    String imageUrl = item?.imageUrl ?? '';
    selectedImage = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add Food' : 'Edit Food'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Food Name'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price (RM)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        selectedImage = File(pickedFile.path);
                        setDialogState(() {});
                      }
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text("Upload Image"),
                  ),
                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.file(selectedImage!, height: 100),
                    ),
                  DropdownButton<String>(
                    value: category,
                    items: const [
                      DropdownMenuItem(value: 'food', child: Text('Food')),
                      DropdownMenuItem(value: 'drink', child: Text('Drink')),
                    ],
                    onChanged: (value) => setDialogState(() => category = value!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (selectedImage != null) {
                    imageUrl = await storage.uploadFoodImage(selectedImage!);
                  }

                  if (nameController.text.trim().isEmpty ||
                      priceController.text.trim().isEmpty ||
                      imageUrl.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Name, price and image are required."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final newItem = FoodItem(
                    id: item?.id ?? '',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.tryParse(priceController.text.trim()) ?? 0,
                    imageUrl: imageUrl,
                    category: category,
                  );

                  if (item == null) {
                    final docRef = await FirebaseFirestore.instance
                        .collection('food_items')
                        .add(newItem.toMap());
                    await docRef.update({'id': docRef.id});
                  } else {
                    await firestore.updateFoodItem(newItem);
                  }

                  Navigator.pop(context);
                  setState(() {
                    selectedImage = null;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("❌ Error: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Food')),
      body: FutureBuilder<List<FoodItem>>(
        future: firestore.getMenuItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("RM ${item.price.toStringAsFixed(2)} (${item.category})\n${item.description}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => showFoodForm(item: item),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () async {
                          await firestore.deleteFoodItem(item.id);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFoodForm(),
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
