import 'package:flutter/foundation.dart';
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';
import 'package:doanflutter/features/booking/data/models/booking_model.dart'; // Đảm bảo bạn đã import BookingModel
import 'package:doanflutter/features/booking/domain/repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _bookingRepository;

  BookingProvider(this._bookingRepository);

  // Trạng thái cho danh sách booking
  List<BookingEntity> _myBookings = [];
  List<BookingEntity> get myBookings => _myBookings;
  List<BookingEntity> get upcomingBookings {
    final now = DateTime.now();
    // Lấy các booking chưa bắt đầu VÀ có status là pending hoặc confirmed
    return _myBookings.where((b) {
      return (b.status == 'pending' || b.status == 'confirmed') &&
             b.checkIn.isAfter(now); // Chỉ lấy những booking trong tương lai
    }).toList();
  }

  List<BookingEntity> get completedBookings {
    final now = DateTime.now();
    // Lấy các booking đã check-out HOẶC ngày check-out đã qua VÀ status là confirmed/checked_in
    return _myBookings.where((b) {
      return b.status == 'checked_out' ||
             ((b.status == 'confirmed' || b.status == 'checked_in') && b.checkOut.isBefore(now));
    }).toList();
  }

  List<BookingEntity> get cancelledBookings {
    return _myBookings.where((b) => b.status == 'canceled').toList();
  }
  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  // Trạng thái cho việc tạo booking mới
  bool _isCreatingBooking = false;
  bool get isCreatingBooking => _isCreatingBooking;

  String? _error;
  String? get error => _error;

  // Lấy danh sách booking của user
  Future<void> fetchMyBookings(String userId) async {
    _isLoadingList = true;
    _error = null;
    notifyListeners();
    try {
      _myBookings = await _bookingRepository.fetchBookingsForUser(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingList = false;
    notifyListeners();
  }

  // Tạo một booking mới
  Future<void> createBooking(BookingEntity booking) async {
    _isCreatingBooking = true;
    _error = null;
    notifyListeners();
    try {
      await _bookingRepository.createBooking(booking);
      // Sau khi tạo thành công, tự động tải lại danh sách
      await fetchMyBookings(booking.userId);
    } catch (e) {
      _error = e.toString();
      // Ném lỗi ra để BookingScreen có thể bắt và hiển thị
      throw Exception(e);
    } finally {
      _isCreatingBooking = false;
      notifyListeners();
    }
  }

  // --- THÊM PHƯƠNG THỨC HỦY PHÒNG ---
  Future<void> cancelBookingByUser(String bookingId, String userId) async {
    _error = null;
    try {
      // Gọi repository để cập nhật status thành 'canceled'
      await _bookingRepository.updateBookingStatus(bookingId, 'canceled');

      // Cập nhật trạng thái trong UI ngay lập tức
      // Tìm booking trong danh sách _myBookings và cập nhật status
      final index = _myBookings.indexWhere((b) => b.bookingId == bookingId);
      if (index != -1) {
        // Tạo một bản sao của booking cũ với status mới
        final oldBooking = _myBookings[index];
        _myBookings[index] = BookingModel( // Giả sử bạn có BookingModel
          bookingId: oldBooking.bookingId,
          userId: oldBooking.userId,
          ownerId: oldBooking.ownerId,
          hotelId: oldBooking.hotelId,
          hotelName: oldBooking.hotelName,
          roomId: oldBooking.roomId,
          roomType: oldBooking.roomType,
          checkIn: oldBooking.checkIn,
          checkOut: oldBooking.checkOut,
          totalPrice: oldBooking.totalPrice,
          status: 'canceled', // Cập nhật status
        );
         notifyListeners(); // Thông báo thay đổi UI
      }
      // Không cần fetch lại toàn bộ danh sách nếu chỉ cập nhật 1 item

    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // Ném lỗi ra để UI có thể hiển thị thông báo
      throw Exception('Hủy phòng thất bại: ${e.toString()}');
    }
  }
  // ------------------------------------

  // Trạng thái cho danh sách booking của người quản lý
  List<BookingEntity> _adminBookings = [];
  List<BookingEntity> get adminBookings => _adminBookings;

  bool _isLoadingAdminList = false;
  bool get isLoadingAdminList => _isLoadingAdminList;

  // Lấy danh sách booking của người quản lý
  Future<void> fetchBookingsForOwner(String ownerId) async {
    _isLoadingAdminList = true;
    _error = null;
    notifyListeners();

    try {
      _adminBookings = await _bookingRepository.fetchBookingsForOwner(ownerId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoadingAdminList = false;
    notifyListeners();
  }

  // Cập nhật trạng thái booking (Dùng chung cho cả admin và user hủy)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingRepository.updateBookingStatus(bookingId, status);
      // Cập nhật cả 2 danh sách trong provider
      _updateStatusInList(_myBookings, bookingId, status);
      _updateStatusInList(_adminBookings, bookingId, status);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception(e);
    }
  }

  // Hàm helper để cập nhật status trong một list cụ thể
  void _updateStatusInList(List<BookingEntity> list, String bookingId, String status) {
    final index = list.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final oldBooking = list[index];
      // Tạo object mới với status đã cập nhật
      list[index] = BookingModel(
        bookingId: oldBooking.bookingId,
        userId: oldBooking.userId,
        ownerId: oldBooking.ownerId,
        hotelId: oldBooking.hotelId,
        hotelName: oldBooking.hotelName,
        roomId: oldBooking.roomId,
        roomType: oldBooking.roomType,
        checkIn: oldBooking.checkIn,
        checkOut: oldBooking.checkOut,
        totalPrice: oldBooking.totalPrice,
        status: status, // Status mới
      );
    }
  }
}