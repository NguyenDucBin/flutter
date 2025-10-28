// lib/features/rooms/data/repositories/room_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/domain/repositories/room_repository.dart';
import 'package:doanflutter/features/rooms/data/models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _db;
  RoomRepositoryImpl(this._db);

  // Helper để lấy collection 'rooms' của một khách sạn
  CollectionReference _roomsCol(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('rooms');

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
      imageUrls: room.imageUrls, // <-- THÊM DÒNG NÀY
      amenities: room.amenities, // <-- THÊM DÒNG NÀY
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
      imageUrls: room.imageUrls, // <-- THÊM DÒNG NÀY
      amenities: room.amenities, // <-- THÊM DÒNG NÀY
    );
    // Dùng .doc(roomId).update() để cập nhật phòng đã có
    await _roomsCol(room.hotelId).doc(room.roomId).update(model.toMap());
  }
}