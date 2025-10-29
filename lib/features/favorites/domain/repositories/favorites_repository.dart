abstract class FavoritesRepository {
  // Lấy danh sách ID khách sạn yêu thích
  Future<List<String>> getFavoriteIds(String userId);

  // Thêm/bỏ yêu thích
  Future<void> toggleFavorite(String userId, String hotelId, bool isCurrentlyFavorite);
}