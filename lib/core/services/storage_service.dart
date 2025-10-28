import 'dart:io';
import 'dart:typed_data';
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

  Future<String> uploadImageBytes(
    Uint8List bytes,
    String folder, {
    String? fileName,
    String contentType = 'image/jpeg',
  }) async {
    final String safeName =
        fileName ?? 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref('$folder/$safeName');
    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return await task.ref.getDownloadURL();
  }

  // (Giữ nguyên hàm upload bằng File nếu bạn còn dùng cho mobile)
}