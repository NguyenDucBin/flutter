import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Hàm tải file lên và trả về URL
  Future<String> uploadImage(File file, String path) async {
    // path ví dụ: 'rooms/' hoặc 'hotels/'
    final ref = _storage.ref().child('$path/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    final url = await task.ref.getDownloadURL();
    return url;
  }
}