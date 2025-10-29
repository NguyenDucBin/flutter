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

// 3. Tự động cập nhật minPrice của khách sạn khi phòng thay đổi
exports.updateHotelMinPrice = functions.firestore
  .document("hotels/{hotelId}/rooms/{roomId}")
  .onWrite(async (change, context) => {
    // Lấy hotelId từ tham số (ví dụ: "hotels/ABC/rooms/123" -> hotelId = "ABC")
    const hotelId = context.params.hotelId;
    const hotelRef = db.collection("hotels").doc(hotelId);

    // Lấy tài liệu khách sạn hiện tại để đọc minPrice cũ
    const hotelDoc = await hotelRef.get();
    if (!hotelDoc.exists) {
      console.log("Khách sạn không tồn tại:", hotelId);
      return null;
    }
    const currentMinPrice = hotelDoc.data().minPrice;

    // Lấy tất cả các phòng của khách sạn này
    const roomsSnapshot = await hotelRef.collection("rooms").get();

    let newMinPrice = 0.0; // Giá tối thiểu mới, mặc định là 0

    if (!roomsSnapshot.empty) {
      // Lọc ra tất cả các mức giá hợp lệ (là số và > 0)
      const prices = roomsSnapshot.docs
        .map((doc) => doc.data().pricePerNight)
        .filter((price) => typeof price === "number" && price > 0);
      
      if (prices.length > 0) {
        // Tìm giá thấp nhất trong các giá hợp lệ
        newMinPrice = Math.min(...prices);
      }
    }
    
    // Chỉ cập nhật Firestore nếu giá mới khác giá cũ
    // Điều này giúp tiết kiệm chi phí (lượt ghi)
    if (currentMinPrice !== newMinPrice) {
      console.log(
        `Cập nhật minPrice cho hotel ${hotelId}: ${currentMinPrice} -> ${newMinPrice}`
      );
      // Thực hiện cập nhật
      return hotelRef.update({ minPrice: newMinPrice });
    }
    
    // Không cần cập nhật
    console.log(`minPrice cho hotel ${hotelId} đã là ${newMinPrice}. Không cập nhật.`);
    return null;
  });