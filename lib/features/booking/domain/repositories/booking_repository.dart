import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  // Dành cho Khách hàng
  Future<void> createBooking(BookingEntity booking);
  Future<List<BookingEntity>> fetchBookingsForUser(String userId);

  // Dành cho Chủ khách sạn (Admin)
  Future<List<BookingEntity>> fetchBookingsForOwner(String ownerId);
  Future<void> cancelBooking(String bookingId);
  Future<void> updateBookingStatus(String bookingId, String status);
}