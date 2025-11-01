import '../entities/room_entity.dart'; 
abstract class RoomRepository {
  // USER + ADMIN: xem danh sách tất cả phòng trong khách sạn
  Future<List<RoomEntity>> fetchRooms(String hotelId);
  Future<List<RoomEntity>> getAvailableRooms(
    String hotelId,
    DateTime checkIn,
    DateTime checkOut,
  );
  // ADMIN: tạo, cập nhật, xóa phòng
  Future<void> createRoom(RoomEntity room);
  Future<void> updateRoom(RoomEntity room); 
  Future<void> deleteRoom(String hotelId, String roomId); 
}