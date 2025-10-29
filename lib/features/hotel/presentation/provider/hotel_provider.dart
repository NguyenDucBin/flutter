import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/data/models/hotel_model.dart';
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

  // --- STATE MỚI CHO LỌC/TÌM KIẾM ---
  String _searchQuery = '';
  double _minPrice = 0.0;
  double _maxPrice = 10000000.0; // Mặc định giá tối đa (10 triệu)
  List<String> _selectedAmenities = [];

  // Getters cho UI
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => RangeValues(_minPrice, _maxPrice);
  List<String> get selectedAmenities => _selectedAmenities;

  // Setters cho UI
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // Thông báo để UI (filteredHotels) cập nhật
  }

  void setPriceRange(RangeValues values) {
    _minPrice = values.start;
    _maxPrice = values.end;
    notifyListeners();
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }

  // --- GETTER MỚI CHO DANH SÁCH ĐÃ LỌC ---
  List<HotelEntity> get filteredHotels {
    // SỬA LỖI Gõ: Dùng List.from(_allHotels) để tạo bản sao mới
    List<HotelEntity> filtered = List<HotelEntity>.from(_allHotels);

    // 1. Lọc theo tên
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              h.address.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Lọc theo giá (minPrice của khách sạn phải nằm trong khoảng)
    filtered = filtered
        .where((h) =>
            (h.minPrice >= _minPrice) &&
            (h.minPrice <= _maxPrice || _maxPrice >= 10000000.0))
        .toList();

    // 3. Lọc theo tiện ích (Khách sạn phải có TẤT CẢ tiện ích đã chọn)
    if (_selectedAmenities.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              _selectedAmenities.every((amenity) => h.amenities.contains(amenity)))
          .toList();
    }
    
    return filtered;
  }

  // Action: Tải TẤT CẢ khách sạn (cho Khách hàng)
  Future<void> fetchAllHotels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // SỬA LỖI Gõ: Ép kiểu tường minh sang List<HotelEntity>
      final fetchedHotels = await _hotelRepository.fetchAllHotels();
      _allHotels = List<HotelEntity>.from(fetchedHotels);
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
      // SỬA LỖI Gõ: Ép kiểu tường minh sang List<HotelEntity>
      final fetchedHotels = await _hotelRepository.fetchHotelsForOwner(ownerId);
      _myHotels = List<HotelEntity>.from(fetchedHotels);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Action: Thêm khách sạn (cho Admin)
  Future<void> createHotel(HotelEntity hotel) async {
    // Lấy ownerId ra trước vì `hotel` có thể bị thay đổi
    final ownerId = hotel.ownerId;
    try {
      await _hotelRepository.createHotel(hotel);
      
      // SỬA LỖI LOGIC: Không thêm `hotel` vào list
      // Thay vào đó, tải lại danh sách để lấy ID mới từ Firestore
      await fetchMyHotels(ownerId);
      // fetchMyHotels đã bao gồm notifyListeners()

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
      // Xóa khỏi danh sách UI và thông báo (Cách này ổn)
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
        // Cập nhật UI (Cách này ổn vì đã fix lỗi ép kiểu ở fetchMyHotels)
        _myHotels[index] = hotel;
      }
      
      // Cập nhật lại cả danh sách public
      await fetchAllHotels();

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
      orElse: () => HotelModel.empty(),
    );
    return hotel.name;
  }

  // Helper: Lấy ID chủ khách sạn
  String? getHotelOwnerId(String hotelId) {
    final hotel = _allHotels.firstWhere(
      (h) => h.id == hotelId,
      orElse: () => HotelModel.empty(),
    );
    return hotel.ownerId;
  }

  // Helper: Lấy thông tin khách sạn từ ID
  HotelEntity? getHotelById(String hotelId) {
    try {
      // Nên tìm trong _allHotels vì nó chứa tất cả
      return _allHotels.firstWhere((h) => h.id == hotelId);
    } catch (e) {
      // Nếu không thấy, thử tìm trong _myHotels (phòng trường hợp)
      try {
         return _myHotels.firstWhere((h) => h.id == hotelId);
      } catch (e) {
        return null;
      }
    }
  }
}