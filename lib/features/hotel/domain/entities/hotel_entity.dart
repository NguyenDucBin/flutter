import 'package:equatable/equatable.dart';

class HotelEntity extends Equatable {
  final String id;
  final String ownerId; // ID của chủ khách sạn
  final String name;
  final String address;
  final String description;
  final List<String> imageUrls; // Danh sách link ảnh
  final List<String> amenities; // Danh sách tiện ích (wifi, pool...)
  final double minPrice;      // Giá phòng thấp nhất
  final double avgRating;     // Điểm đánh giá trung bình
  final int reviewCount;    // Số lượng đánh giá

  const HotelEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    this.description = '',
    this.imageUrls = const [],
    this.amenities = const [],
    this.minPrice = 0.0,
    this.avgRating = 0.0,
    this.reviewCount = 0,
  });

  factory HotelEntity.empty() {
    return const HotelEntity(
      id: '',
      ownerId: '',
      name: '',
      address: '',
      minPrice: 0.0,
      avgRating: 0.0,
      reviewCount: 0,
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
      minPrice,
      avgRating,
      reviewCount,
    ];
  }
}