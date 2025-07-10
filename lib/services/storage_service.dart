import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFoodImage(File imageFile) async {
    try {
      final fileName = const Uuid().v4(); // generate unique ID
      final ref = _storage.ref().child('food_images/$fileName.jpg');

      // Upload file
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Image upload failed: $e');
      rethrow;
    }
  }
}
