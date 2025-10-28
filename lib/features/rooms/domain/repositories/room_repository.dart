//import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import '../entities/room_entity.dart'; // <--- THÊM DÒNG NÀY
abstract class RoomRepository {
  Future<List<RoomEntity>> fetchRooms(String hotelId);
  Future<List<RoomEntity>> getAvailableRooms(
    String hotelId,
    DateTime checkIn,
    DateTime checkOut,
  );
  Future<void> createRoom(RoomEntity room);
  Future<void> updateRoom(RoomEntity room); // <-- Đã thêm
  Future<void> deleteRoom(String hotelId, String roomId); // <-- Đã thêm
}