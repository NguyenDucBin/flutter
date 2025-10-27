import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper để lấy collection reference
  CollectionReference collection(String path) => _db.collection(path);
}