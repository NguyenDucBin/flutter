import 'package:flutter/foundation.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/domain/repositories/hotel_repository.dart';

class HotelProvider extends ChangeNotifier {
  final HotelRepository _hotelRepository;
  HotelProvider(this._hotelRepository);

  // State cho Khách hàng xem
  List<HotelEntity> _allHotels = [];
  List<HotelEntity> get allHotels => _allHotels;

  // State cho Admin quản lý
  List<HotelEntity> _myHotels = [];
  List<HotelEntity> get myHotels => _myHotels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  // Action: Tải TẤT CẢ khách sạn (cho Khách hàng)
  Future<void> fetchAllHotels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allHotels = await _hotelRepository.fetchAllHotels();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Action: Tải khách sạn CỦA TÔI (cho Admin)
  Future<void> fetchMyHotels(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _myHotels = await _hotelRepository.fetchHotelsForOwner(ownerId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Action: Thêm khách sạn (cho Admin)
  Future<void> createHotel(HotelEntity hotel) async {
    try {
      await _hotelRepository.createHotel(hotel);
      // Thêm vào danh sách UI và thông báo
      _myHotels.add(hotel); // Cần có ID trả về, tạm thời thêm
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception(e); // Ném lỗi ra để UI bắt
    }
  }

  // Action: Xóa khách sạn (cho Admin)
  Future<void> deleteHotel(String hotelId) async {
    try {
      await _hotelRepository.deleteHotel(hotelId);
      // Xóa khỏi danh sách UI và thông báo
      _myHotels.removeWhere((h) => h.id == hotelId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Action: Cập nhật khách sạn (cho Admin)
  Future<void> updateHotel(HotelEntity hotel) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _hotelRepository.updateHotel(hotel);
      final index = _myHotels.indexWhere((h) => h.id == hotel.id);
      if (index != -1) {
        _myHotels[index] = hotel;
      }
    } catch (e) {
      _error = e.toString();
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper: Lấy tên khách sạn từ ID
  String? getHotelName(String hotelId) {
    final hotel = _allHotels.firstWhere(
      (h) => h.id == hotelId,
      orElse: () => HotelEntity.empty(),
    );
    return hotel.name;
  }

  // Helper: Lấy ID chủ khách sạn
  String? getHotelOwnerId(String hotelId) {
    final hotel = _allHotels.firstWhere(
      (h) => h.id == hotelId,
      orElse: () => HotelEntity.empty(),
    );
    return hotel.ownerId;
  }

  // Helper: Lấy thông tin khách sạn từ ID
  HotelEntity? getHotelById(String hotelId) {
    try {
      return _allHotels.firstWhere((h) => h.id == hotelId);
    } catch (e) {
      return null;
    }
  }
}