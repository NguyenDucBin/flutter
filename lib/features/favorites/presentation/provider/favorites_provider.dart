import 'package:flutter/foundation.dart';
import 'package:doanflutter/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository _repository;
  FavoritesProvider(this._repository);

  List<String> _favoriteHotelIds = [];
  List<String> get favoriteHotelIds => _favoriteHotelIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isFavorite(String hotelId) {
    return _favoriteHotelIds.contains(hotelId);
  }

  Future<void> fetchFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();
    _favoriteHotelIds = await _repository.getFavoriteIds(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String userId, String hotelId) async {
    final bool currentlyFavorite = isFavorite(hotelId);
    
    // Cập nhật UI ngay lập tức
    if (currentlyFavorite) {
      _favoriteHotelIds.remove(hotelId);
    } else {
      _favoriteHotelIds.add(hotelId);
    }
    notifyListeners();

    // Gọi API
    try {
      await _repository.toggleFavorite(userId, hotelId, currentlyFavorite);
    } catch (e) {
      // Nếu lỗi, rollback UI
      if (currentlyFavorite) {
        _favoriteHotelIds.add(hotelId);
      } else {
        _favoriteHotelIds.remove(hotelId);
      }
      notifyListeners();
      // Ném lỗi ra để UI xử lý
      throw Exception("Lỗi cập nhật yêu thích: $e");
    }
  }
}