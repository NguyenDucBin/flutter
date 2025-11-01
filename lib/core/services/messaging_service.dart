import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';  


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Bạn có thể xử lý logic thông báo nền ở đây
  debugPrint("Handling a background message: ${message.messageId}");
}

class MessagingService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Future<void> initAndSaveToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _fm.requestPermission(); // Yêu cầu quyền

    final token = await _fm.getToken();
    if (token != null) {
      debugPrint("FCM Token: $token"); // In token ra để debug
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }

    // THÊM CÁC HÀM LẮNG NGHE
    _setupListeners();
  }

  void _setupListeners() {
    // 1. Xử lý khi app đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        // TODO: Hiển thị thông báo (ví dụ: dùng package flutter_local_notifications)
        // Ví dụ: localNotificationsPlugin.show( ... );
      }
    });

    // 2. Xử lý khi nhấn vào thông báo (mở app từ trạng thái terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state by notification: ${message.data}');
        // TODO: Điều hướng đến trang liên quan (ví dụ: trang Booking)
        // _handleNotificationNavigation(message.data);
      }
    });

    // 3. Xử lý khi nhấn vào thông báo (mở app từ trạng thái background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from background state by notification: ${message.data}');
      // TODO: Điều hướng đến trang liên quan
      // _handleNotificationNavigation(message.data);
    });
  }

  // (Bạn có thể thêm hàm _handleNotificationNavigation(Map<String, dynamic> data) ở đây)
}