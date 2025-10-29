// lib/features/auth/data/datasources/auth_firebase_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthFirebaseDataSource(this._auth, this._firestore);

  // Lấy stream người dùng từ Firebase Auth
  Stream<User?> get userStream => _auth.authStateChanges();

  // Đăng nhập
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- SỬA HÀM NÀY: Bỏ tham số 'role' VÀ đặt cứng 'customer' ---
  // Đăng ký
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    // required String role, // <-- ĐÃ XÓA
  }) async {
    // 1. Tạo user trong Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // 2. Tạo document trong collection 'users' trên Firestore
    // để lưu trữ thông tin bổ sung (name, role)
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': 'customer', // <-- SỬA Ở ĐÂY: Mặc định là 'customer'
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Hàm helper để lấy thông tin 'role' từ Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['role'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}