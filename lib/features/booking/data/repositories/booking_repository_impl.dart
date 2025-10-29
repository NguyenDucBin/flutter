import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; 
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';
import 'package:doanflutter/features/booking/domain/repositories/booking_repository.dart';
import 'package:doanflutter/features/booking/data/models/booking_model.dart';
import 'package:firebase_core/firebase_core.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _db;
  BookingRepositoryImpl(this._db);

  // Helper lấy collection 'bookings'
  CollectionReference get _bookingsCol => _db.collection('bookings');

  @override
  Future<void> createBooking(BookingEntity booking) async {
    // Chuyển Entity sang Model để dùng hàm toMap()
    final bookingModel = BookingModel(
      userId: booking.userId,
      ownerId: booking.ownerId,
      hotelId: booking.hotelId,
      hotelName: booking.hotelName,
      roomId: booking.roomId,
      roomType: booking.roomType,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      totalPrice: booking.totalPrice,
      status: booking.status,
    );

    // Dùng Transaction để đảm bảo tính toàn vẹn dữ liệu
    await _db.runTransaction((transaction) async {
      // 1. Tìm các booking bị xung đột
      final conflictingBookings = await _bookingsCol
          .where('roomId', isEqualTo: booking.roomId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      // 2. Kiểm tra xung đột logic trong Dart
      for (var doc in conflictingBookings.docs) {
        final existingBooking = BookingModel.fromSnapshot(doc);
        // Logic kiểm tra 2 khoảng thời gian giao nhau:
        // (StartA < EndB) và (StartB < EndA)
        if (booking.checkIn.isBefore(existingBooking.checkOut) &&
            existingBooking.checkIn.isBefore(booking.checkOut)) {
          // Nếu có 1 booking bị trùng -> ném lỗi
          throw Exception('Phòng đã được đặt trong khoảng thời gian này.');
        }
      }

      // 3. Nếu không có xung đột, tạo booking mới
      final newDocRef = _bookingsCol.doc();
      transaction.set(newDocRef, bookingModel.toMap());
    });
  }

  @override
  Future<List<BookingEntity>> fetchBookingsForUser(String userId) async {
    final snapshot = await _bookingsCol
        .where('userId', isEqualTo: userId)
        .orderBy('checkIn', descending: true)
        .get();
    return snapshot.docs
        .map<BookingEntity>((doc) => BookingModel.fromSnapshot(doc))
        .toList();
  }

  @override
  Future<List<BookingEntity>> fetchBookingsForOwner(String ownerId) async {
    try {
      final snapshot = await _bookingsCol
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('status')   // đảm bảo thứ tự + direction khớp index
          .orderBy('checkIn')  // đảm bảo thứ tự + direction khớp index
          .get();

      return snapshot.docs
          .map<BookingEntity>((doc) => BookingModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore index required: ${e.message}');
      return <BookingEntity>[];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _bookingsCol.doc(bookingId).update({'status': 'canceled'});
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingsCol.doc(bookingId).update({'status': status});
  }
}