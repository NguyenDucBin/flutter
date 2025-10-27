import 'package:equatable/equatable.dart';

class HotelEntity extends Equatable {
  final String id;
  final String ownerId; // ID của chủ khách sạn
  final String name;
  final String address;
  final String description;
  final List<String> imageUrls; // Danh sách link ảnh
  final List<String> amenities; // Danh sách tiện ích (wifi, pool...)

  const HotelEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    this.description = '',
    this.imageUrls = const [],
    this.amenities = const [],
  });

  factory HotelEntity.empty() {
    return const HotelEntity(
      id: '',
      ownerId: '',
      name: '',
      address: '',
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      ownerId,
      name,
      address,
      description,
      imageUrls,
      amenities,
    ];
  }
}