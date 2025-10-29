import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';

abstract class HotelRepository {
  // Lấy tất cả khách sạn (cho khách hàng xem)
  Future<List<HotelEntity>> fetchAllHotels();

  // Lấy các khách sạn của một chủ sở hữu (cho admin)
  Future<List<HotelEntity>> fetchHotelsForOwner(String ownerId);

  // Thêm một khách sạn mới
  Future<void> createHotel(HotelEntity hotel);

  // Cập nhật thông tin khách sạn
  Future<void> updateHotel(HotelEntity hotel);

  // Xóa một khách sạn
  Future<void> deleteHotel(String hotelId);
  
  // Cập nhật giá thấp nhất của khách sạn
  Future<void> updateHotelMinPrice(String hotelId, double minPrice);
}