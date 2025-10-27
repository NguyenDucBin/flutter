import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagingService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  // Lấy token và lưu vào 'users' collection
  Future<void> initAndSaveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Yêu cầu quyền (iOS / Android 13+)
    await _fm.requestPermission();

    final token = await _fm.getToken();
    if (token != null) {
      // Lưu token vào document của user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }
  }
}