import '../entities/room_entity.dart'; 
abstract class RoomRepository {
  Future<List<RoomEntity>> fetchRooms(String hotelId);
  Future<List<RoomEntity>> getAvailableRooms(
    String hotelId,
    DateTime checkIn,
    DateTime checkOut,
  );
  Future<void> createRoom(RoomEntity room);
  Future<void> updateRoom(RoomEntity room); 
  Future<void> deleteRoom(String hotelId, String roomId); 
}