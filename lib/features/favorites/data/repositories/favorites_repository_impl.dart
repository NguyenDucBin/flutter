import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore _db;
  FavoritesRepositoryImpl(this._db);

  DocumentReference _userDoc(String userId) => _db.collection('users').doc(userId);

  @override
  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Lấy mảng 'favorites', nếu không có thì trả về mảng rỗng
        return List<String>.from(data['favorites'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> toggleFavorite(String userId, String hotelId, bool isCurrentlyFavorite) async {
    if (isCurrentlyFavorite) {
      // Bỏ yêu thích
      await _userDoc(userId).update({
        'favorites': FieldValue.arrayRemove([hotelId])
      });
    } else {
      // Thêm yêu thích
      await _userDoc(userId).update({
        'favorites': FieldValue.arrayUnion([hotelId])
      });
    }
  }
}