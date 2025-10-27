import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/domain/repositories/room_repository.dart';
import 'package:doanflutter/features/rooms/data/models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _db;
  RoomRepositoryImpl(this._db);

  @override
  Future<void> createRoom(RoomEntity room) async {
    // Chuyển Entity thành Model để lấy hàm toMap
    final model = RoomModel(
      roomId: room.roomId,
      hotelId: room.hotelId,
      type: room.type,
      pricePerNight: room.pricePerNight,
      capacity: room.capacity,
      available: room.available,
    );
    await _db.collection('hotels').doc(room.hotelId).collection('rooms').add(model.toMap());
  }

  @override
  Future<void> deleteRoom(String hotelId, String roomId) async {
    await _db.collection('hotels').doc(hotelId).collection('rooms').doc(roomId).delete();
  }

  @override
  Future<List<RoomEntity>> fetchRooms(String hotelId) async {
    final snap = await _db.collection('hotels').doc(hotelId).collection('rooms').get();
    // Tự động chuyển đổi list Document về list Model (cũng là list Entity)
    return snap.docs.map((d) => RoomModel.fromSnapshot(d)).toList();
  }

  @override
  Future<void> updateRoom(RoomEntity room) async {
    final model = RoomModel(
      roomId: room.roomId,
      hotelId: room.hotelId,
      type: room.type,
      pricePerNight: room.pricePerNight,
      capacity: room.capacity,
      available: room.available,
    );
    await _db
        .collection('hotels')
        .doc(room.hotelId)
        .collection('rooms')
        .doc(room.roomId)
        .update(model.toMap());
  }
}