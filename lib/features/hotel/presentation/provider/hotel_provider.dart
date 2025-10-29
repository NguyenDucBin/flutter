import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/data/models/hotel_model.dart';
import 'package:doanflutter/features/hotel/domain/repositories/hotel_repository.dart';

class HotelProvider extends ChangeNotifier {
  final HotelRepository _hotelRepository;
  HotelProvider(this._hotelRepository);

  // --- STATE CƠ BẢN ---
  List<HotelEntity> _allHotels = [];
  List<HotelEntity> get allHotels => _allHotels;

  List<HotelEntity> _myHotels = [];
  List<HotelEntity> get myHotels => _myHotels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  // --- STATE CHO LỌC/TÌM KIẾM ---
  String _searchQuery = '';
  double _minPrice = 0.0;
  double _maxPrice = 10000000.0;
  List<String> _selectedAmenities = [];

  // --- STATE CHO NGÀY ---
  DateTime? startDate;
  DateTime? endDate;

  // Getters cho UI
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => RangeValues(_minPrice, _maxPrice);
  List<String> get selectedAmenities => _selectedAmenities;

  // --- SETTERS CHO UI ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
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

  // 🔹 Thêm mới: Lưu ngày nhận & trả phòng
  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }

  // --- LỌC KHÁCH SẠN ---
  List<HotelEntity> get filteredHotels {
    List<HotelEntity> filtered = List<HotelEntity>.from(_allHotels);

    // 1. Tên hoặc địa chỉ
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              h.address.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Giá
    filtered = filtered
        .where((h) =>
            (h.minPrice >= _minPrice) &&
            (h.minPrice <= _maxPrice || _maxPrice >= 10000000.0))
        .toList();

    // 3. Tiện ích
    if (_selectedAmenities.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              _selectedAmenities.every((amenity) => h.amenities.contains(amenity)))
          .toList();
    }

    // 🔹 (Tuỳ chọn) sau này có thể thêm lọc theo ngày ở đây nếu có dữ liệu phòng trống

    return filtered;
  }

  // --- ACTION: FETCH ---
  Future<void> fetchAllHotels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetchedHotels = await _hotelRepository.fetchAllHotels();
      _allHotels = List<HotelEntity>.from(fetchedHotels);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyHotels(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetchedHotels = await _hotelRepository.fetchHotelsForOwner(ownerId);
      _myHotels = List<HotelEntity>.from(fetchedHotels);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- CRUD ---
  Future<void> createHotel(HotelEntity hotel) async {
    final ownerId = hotel.ownerId;
    try {
      await _hotelRepository.createHotel(hotel);
      await fetchMyHotels(ownerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception(e);
    }
  }

  Future<void> deleteHotel(String hotelId) async {
    try {
      await _hotelRepository.deleteHotel(hotelId);
      _myHotels.removeWhere((h) => h.id == hotelId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

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
      await fetchAllHotels();
    } catch (e) {
      _error = e.toString();
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HELPER ---
  String? getHotelName(String hotelId) {
    final hotel = _allHotels.firstWhere(
      (h) => h.id == hotelId,
      orElse: () => HotelModel.empty(),
    );
    return hotel.name;
  }

  String? getHotelOwnerId(String hotelId) {
    final hotel = _allHotels.firstWhere(
      (h) => h.id == hotelId,
      orElse: () => HotelModel.empty(),
    );
    return hotel.ownerId;
  }

  HotelEntity? getHotelById(String hotelId) {
    try {
      return _allHotels.firstWhere((h) => h.id == hotelId);
    } catch (e) {
      try {
        return _myHotels.firstWhere((h) => h.id == hotelId);
      } catch (e) {
        return null;
      }
    }
  }
}
