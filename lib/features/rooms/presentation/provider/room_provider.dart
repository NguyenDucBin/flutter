import 'package:flutter/material.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/domain/repositories/room_repository.dart';
import 'package:doanflutter/features/rooms/data/models/room_model.dart';
import 'package:doanflutter/features/hotel/domain/repositories/hotel_repository.dart';

class RoomProvider extends ChangeNotifier {
  final RoomRepository _roomRepository;
  final HotelRepository _hotelRepository;

  RoomProvider(this._roomRepository, this._hotelRepository);

  List<RoomEntity> _rooms = []; // Dùng cho Admin
  List<RoomEntity> get rooms => _rooms;
  List<RoomEntity> _availableRooms = []; // Dùng cho User

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Helper: Lấy thông tin phòng từ ID (Trả về RoomEntity?)
  // --- ĐÃ SỬA KIỂU TRẢ VỀ VÀ LOGIC ---
  RoomEntity? getRoomById(String roomId) {
    try {
      // Ưu tiên tìm trong danh sách phòng trống (cho User)
      return _availableRooms.firstWhere((r) => r.roomId == roomId);
    } catch (e) {
      // Nếu không thấy, tìm trong danh sách tất cả phòng (cho Admin)
      try {
        return _rooms.firstWhere((r) => r.roomId == roomId);
      } catch (e) {
        return null; // Không tìm thấy ở cả hai danh sách
      }
    }
  }

  // Helper: Lấy loại phòng từ ID (dạng String)
  // --- ĐÃ SỬA LOGIC VÀ XÓA HÀM TRÙNG ---
   String? getRoomType(String roomId) {
    final room = getRoomById(roomId); // Sử dụng hàm getRoomById đã sửa
    return room?.type; // Trả về type nếu room không null
  }


  // Lấy danh sách phòng TRỐNG (lọc theo tìm kiếm) - Dùng cho User trên HotelDetailPage
  List<RoomEntity> get filteredRooms {
    if (_searchQuery.isEmpty) {
      return _availableRooms;
    }
    return _availableRooms
        .where((r) => r.type.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Lấy danh sách TẤT CẢ phòng (cho admin lọc)
  List<RoomEntity> get allFilteredRoomsForAdmin {
     if (_searchQuery.isEmpty) {
      return _rooms;
    }
    return _rooms
        .where((r) => r.type.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Cập nhật query tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Gọi Repository để lấy TẤT CẢ phòng (Dùng cho Admin)
  Future<void> fetchAllRooms(String hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _rooms = await _roomRepository.fetchRooms(hotelId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  //Dùng cho User (Xem phòng trống)
  Future<void> fetchAvailableRooms(
    String hotelId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Gọi hàm repository mới
      _availableRooms =
          await _roomRepository.getAvailableRooms(hotelId, checkIn, checkOut);
    } catch (e) {
      _error = e.toString();
      _availableRooms = []; // Đặt lại danh sách trống nếu có lỗi
    }
    _isLoading = false;
    notifyListeners();
  }

  // Gọi Repository để xóa phòng
  Future<void> deleteRoom(String hotelId, String roomId) async {
    try {
      await _roomRepository.deleteRoom(hotelId, roomId);
      // Xóa phòng khỏi cả hai danh sách UI ngay lập tức
      _rooms.removeWhere((room) => room.roomId == roomId);
      _availableRooms.removeWhere((room) => room.roomId == roomId);
      await _recalculateAndUdpateMinPrice(hotelId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createRoom(RoomEntity room) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _roomRepository.createRoom(room);
      // Sau khi tạo, fetch lại danh sách admin để có ID mới
      await fetchAllRooms(room.hotelId);
      await _recalculateAndUdpateMinPrice(room.hotelId);
    } catch (e) {
      _error = e.toString();
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRoom(RoomEntity room) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _roomRepository.updateRoom(room);
      // Cập nhật trong cả hai danh sách nếu tồn tại
      final index = _rooms.indexWhere((r) => r.roomId == room.roomId);
      if (index != -1) {
        _rooms[index] = room;
      }
      final availableIndex = _availableRooms.indexWhere((r) => r.roomId == room.roomId);
      if (availableIndex != -1) {
        _availableRooms[availableIndex] = room;
      }
      await _recalculateAndUdpateMinPrice(room.hotelId);
    } catch (e) {
      _error = e.toString();
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _recalculateAndUdpateMinPrice(String hotelId) async {
  try {
    // 1. Lấy danh sách phòng mới nhất từ repository
    final allRooms = await _roomRepository.fetchRooms(hotelId);

    double newMinPrice = 0.0; // Giá mặc định nếu không có phòng

    if (allRooms.isNotEmpty) {
      // 2. Lọc ra tất cả các giá hợp lệ (phải lớn hơn 0)
      final prices = allRooms
          .map((r) => r.pricePerNight)
          .where((p) => p > 0);

      if (prices.isNotEmpty) {
        // 3. Tìm giá thấp nhất
        newMinPrice = prices.reduce((min, current) => current < min ? current : min);
      }
      // Nếu 'prices' rỗng (không có phòng, hoặc giá 0), newMinPrice sẽ là 0.0
    }

    // 4. Cập nhật tài liệu khách sạn bằng repository
    await _hotelRepository.updateHotelMinPrice(hotelId, newMinPrice);

  } catch (e) {
    debugPrint('Lỗi khi tính toán minPrice: $e');
    // Không ném lỗi, để hàm gốc (create/update/delete) tiếp tục
  }
}
}