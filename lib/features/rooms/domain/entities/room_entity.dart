// lib/features/rooms/domain/entities/room_entity.dart
import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String roomId;
  final String hotelId;
  final String type;
  final double pricePerNight;
  final int capacity;
  final bool available;
  final List<String> imageUrls; 
  final List<String> amenities;

  const RoomEntity({
    required this.roomId,
    required this.hotelId,
    required this.type,
    required this.pricePerNight,
    required this.capacity,
    required this.available,
    this.imageUrls = const [], 
    this.amenities = const [], 
  });

  // Add empty factory constructor
  factory RoomEntity.empty() {
    return const RoomEntity(
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

  @override
  List<Object?> get props => [
        roomId,
        hotelId,
        type,
        pricePerNight,
        capacity,
        available,
        imageUrls, 
        amenities, 
      ];
}