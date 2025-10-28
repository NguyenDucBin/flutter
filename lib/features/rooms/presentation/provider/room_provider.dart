import 'package:flutter/material.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/domain/repositories/room_repository.dart';
import 'package:doanflutter/features/rooms/data/models/room_model.dart'; // <-- THÊM DÒNG NÀY

class RoomProvider extends ChangeNotifier {
  final RoomRepository _roomRepository;

  RoomProvider(this._roomRepository);

  List<RoomEntity> _rooms = [];
  List<RoomEntity> get rooms => _rooms;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Helper: Lấy thông tin phòng từ ID
  RoomEntity? getRoomById(String roomId) {
    try {
      return _rooms.firstWhere((r) => r.roomId == roomId);
    } catch (e) {
      return null;
    }
  }

  // Helper: Lấy loại phòng từ ID
  String? getRoomType(String roomId) {
    final room = _rooms.firstWhere(
      (r) => r.roomId == roomId,
      orElse: () => RoomModel.empty(),
    );
    return room.type;
  }

  // Lấy danh sách phòng (lọc theo tìm kiếm)
  List<RoomEntity> get filteredRooms {
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

  // Gọi Repository để lấy dữ liệu từ Firebase
  Future<void> fetchRooms(String hotelId) async {
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

  // Gọi Repository để xóa phòng
  Future<void> deleteRoom(String hotelId, String roomId) async {
    try {
      await _roomRepository.deleteRoom(hotelId, roomId);
      // Xóa phòng khỏi danh sách UI ngay lập tức
      _rooms.removeWhere((room) => room.roomId == roomId);
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
      _rooms.add(room);
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
      final index = _rooms.indexWhere((r) => r.roomId == room.roomId);
      if (index != -1) {
        _rooms[index] = room;
      }
    } catch (e) {
      _error = e.toString();
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}