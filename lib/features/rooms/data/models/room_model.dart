import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.roomId,
    required super.hotelId,
    required super.type,
    required super.pricePerNight,
    required super.capacity,
    required super.available,
    required super.imageUrls, 
    required super.amenities, 
  });

  factory RoomModel.empty() {
    return const RoomModel(
      roomId: '',
      hotelId: '',
      type: '',
      pricePerNight: 0,
      capacity: 0,
      available: false,
      imageUrls: [],
      amenities: [],
    );
  }

  // Chuyển đổi từ Firestore Document về Model
  factory RoomModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return RoomModel(
      roomId: snap.id,
      hotelId: data['hotelId'] ?? '',
      type: data['type'] ?? '',
      pricePerNight: (data['pricePerNight'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 0,
      available: data['available'] ?? false,
      // Đọc 2 trường mới (giống HotelModel)
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }

  // Chuyển đổi từ Model về Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'type': type,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'available': available,
      'imageUrls': imageUrls, 
      'amenities': amenities, 
    };
  }
}