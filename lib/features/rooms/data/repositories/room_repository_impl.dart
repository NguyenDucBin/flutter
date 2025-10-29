import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/domain/repositories/room_repository.dart';
import 'package:doanflutter/features/rooms/data/models/room_model.dart';
import 'package:doanflutter/features/booking/data/models/booking_model.dart';


class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _db;
  RoomRepositoryImpl(this._db); // Constructor needs argument

  // Helper để lấy collection 'rooms' của một khách sạn
  CollectionReference _roomsCol(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('rooms');

  CollectionReference get _bookingsCol => _db.collection('bookings');

  @override
  Future<List<RoomEntity>> getAvailableRooms(
    String hotelId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    // Bước A: Lấy TẤT CẢ phòng của khách sạn
    final allRoomsSnapshot = await _roomsCol(hotelId).get();
    final allRooms =
        allRoomsSnapshot.docs.map((d) => RoomModel.fromSnapshot(d)).toList();

    // Bước B: Lấy TẤT CẢ các booking CÓ KHẢ NĂNG XUNG ĐỘT
    // (tức là của khách sạn này VÀ có status là pending/confirmed)
    final conflictingBookingsSnapshot = await _bookingsCol
        .where('hotelId', isEqualTo: hotelId)
        .where('status', whereIn: ['pending', 'confirmed']).get();

    // Dòng này đã đúng trong file bạn cung cấp
    final conflictingBookings = conflictingBookingsSnapshot.docs
        .map((d) => BookingModel.fromSnapshot(d))
        .toList();

    // Bước C & D: Lọc trong Dart
    final availableRooms = <RoomEntity>[];

    for (final room in allRooms) {
      bool isAvailable = true; // Giả sử phòng trống

      // Tìm các booking của CHỈ RIÊNG phòng này
      final bookingsForThisRoom =
          conflictingBookings.where((b) => b.roomId == room.roomId);

      // Kiểm tra xung đột thời gian
      for (final existingBooking in bookingsForThisRoom) {
        // Logic kiểm tra giao thoa (overlap):
        // (StartA < EndB) && (StartB < EndA)
        if (checkIn.isBefore(existingBooking.checkOut) &&
            existingBooking.checkIn.isBefore(checkOut)) {
          // Nếu tìm thấy 1 xung đột -> phòng này không trống
          isAvailable = false;
          break; // Thoát vòng lặp (for...in bookingsForThisRoom)
        }
      }

      if (isAvailable) {
        availableRooms.add(room);
      }
    }

    return availableRooms;
  }

  @override
  Future<void> createRoom(RoomEntity room) async {
    // Chuyển Entity thành Model để lấy hàm toMap
    final model = RoomModel(
      roomId: '', // Firestore sẽ tự tạo ID khi dùng .add()
      hotelId: room.hotelId,
      type: room.type,
      pricePerNight: room.pricePerNight,
      capacity: room.capacity,
      available: room.available,
      imageUrls: room.imageUrls,
      amenities: room.amenities,
    );
    // Dùng .add() để Firestore tự tạo ID cho phòng mới
    await _roomsCol(room.hotelId).add(model.toMap());
  }

  @override
  Future<void> deleteRoom(String hotelId, String roomId) async {
    await _roomsCol(hotelId).doc(roomId).delete();
  }

  @override
  Future<List<RoomEntity>> fetchRooms(String hotelId) async {
    final snap = await _roomsCol(hotelId).get();
    // Tự động chuyển đổi list Document về list Model (cũng là list Entity)
    // Model.fromSnapshot đã được cập nhật để xử lý các trường mới
    return snap.docs.map((d) => RoomModel.fromSnapshot(d)).toList();
  }

  @override
  Future<void> updateRoom(RoomEntity room) async {
    // Chuyển Entity thành Model để lấy hàm toMap
    final model = RoomModel(
      roomId: room.roomId, // Dùng ID hiện có khi cập nhật
      hotelId: room.hotelId,
      type: room.type,
      pricePerNight: room.pricePerNight,
      capacity: room.capacity,
      available: room.available,
      imageUrls: room.imageUrls,
      amenities: room.amenities,
    );
    // Dùng .doc(roomId).update() để cập nhật phòng đã có
    await _roomsCol(room.hotelId).doc(room.roomId).update(model.toMap());
  }
}