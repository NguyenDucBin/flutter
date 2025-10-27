import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    super.bookingId,
    required super.userId,
    required super.ownerId,     // 👈 THÊM VÀO
    required super.hotelId,
    required super.hotelName,   // 👈 THÊM VÀO
    required super.roomId,
    required super.roomType,    // 👈 THÊM VÀO
    required super.checkIn,
    required super.checkOut,
    required super.totalPrice,
    required super.status,
  });

  // Chuyển đổi từ Firestore Document về Model
  factory BookingModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: snap.id,
      userId: data['userId'] ?? '',
      ownerId: data['ownerId'] ?? '',       // 👈 THÊM VÀO
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',   // 👈 THÊM VÀO
      roomId: data['roomId'] ?? '',
      roomType: data['roomType'] ?? '',     // 👈 THÊM VÀO
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: (data['checkOut'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'unknown',
    );
  }

  // Chuyển đổi từ Model về Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'ownerId': ownerId,         // 👈 THÊM VÀO
      'hotelId': hotelId,
      'hotelName': hotelName,     // 👈 THÊM VÀO
      'roomId': roomId,
      'roomType': roomType,       // 👈 THÊM VÀO
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}