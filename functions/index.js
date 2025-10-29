const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// 1. Gửi thông báo cho Admin khi có Booking MỚI
exports.onBookingCreated = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    const bookingData = snap.data();
    const ownerId = bookingData.ownerId;
    const hotelName = bookingData.hotelName;

    // Lấy fcmToken của Admin (chủ khách sạn)
    const adminUserDoc = await db.collection("users").doc(ownerId).get();
    if (!adminUserDoc.exists) {
      console.log("Không tìm thấy user admin:", ownerId);
      return null;
    }
    
    const fcmToken = adminUserDoc.data().fcmToken;
    if (!fcmToken) {
      console.log("Admin không có fcmToken:", ownerId);
      return null;
    }

    // Tạo payload thông báo
    const payload = {
      notification: {
        title: "Booking Mới!",
        body: `Bạn có một đặt phòng mới tại ${hotelName}.`,
      },
      data: {
        bookingId: context.params.bookingId,
        screen: "AdminBookingList", // Dữ liệu tùy chỉnh để điều hướng
      },
    };

    // Gửi thông báo
    return admin.messaging().sendToDevice(fcmToken, payload);
  });

// 2. Gửi thông báo cho User khi booking được XÁC NHẬN
exports.onBookingUpdated = functions.firestore
  .document("bookings/{bookingId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    // Chỉ gửi khi status thay đổi từ 'pending' sang 'confirmed'
    if (oldData.status === "pending" && newData.status === "confirmed") {
      const userId = newData.userId;
      const hotelName = newData.hotelName;

      // Lấy fcmToken của User
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        console.log("Không tìm thấy user:", userId);
        return null;
      }
      
      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) {
        console.log("User không có fcmToken:", userId);
        return null;
      }
      
      const payload = {
        notification: {
          title: "Đặt phòng được xác nhận!",
          body: `Đặt phòng của bạn tại ${hotelName} đã được xác nhận.`,
        },
        data: {
          bookingId: context.params.bookingId,
          screen: "BookingList", // Dữ liệu tùy chỉnh để điều hướng
        },
      };

      // Gửi thông báo
      return admin.messaging().sendToDevice(fcmToken, payload);
    }

    return null; // Không làm gì nếu status không đổi
  });