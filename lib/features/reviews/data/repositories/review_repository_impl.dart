import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/reviews/data/models/review_model.dart';
import 'package:doanflutter/features/reviews/domain/entities/review_entity.dart';
import 'package:doanflutter/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _db;
  ReviewRepositoryImpl(this._db);

  // Helper lấy collection 'reviews'
  CollectionReference _reviewsCol(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('reviews');
      
  // Helper lấy document 'hotel'
  DocumentReference _hotelDoc(String hotelId) => 
      _db.collection('hotels').doc(hotelId);

  @override
  Future<List<ReviewEntity>> getReviewsForHotel(String hotelId) async {
    final snapshot = await _reviewsCol(hotelId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> submitReview(ReviewEntity review) async {
    final model = ReviewModel(
      hotelId: review.hotelId,
      userId: review.userId,
      userName: review.userName,
      rating: review.rating,
      comment: review.comment,
      createdAt: DateTime.now(),
    );

    // 👈 SỬ DỤNG TRANSACTION ĐỂ ĐẢM BẢO TOÀN VẸN
    await _db.runTransaction((transaction) async {
      // 1. Thêm review mới
      final newReviewRef = _reviewsCol(review.hotelId).doc();
      transaction.set(newReviewRef, model.toMap());

      // 2. Lấy TẤT CẢ review *hiện có* của khách sạn này (bao gồm cả review vừa thêm)
      // Lưu ý: Chúng ta phải đọc toàn bộ collection trong transaction
      final reviewsSnapshot = await _reviewsCol(review.hotelId).get();
      
      final allRatings = reviewsSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as num? ?? 0.0)
          .toList();
          
      // Thêm rating của review mới vào (vì snapshot có thể chưa kịp cập nhật)
      allRatings.add(review.rating); 

      // 3. Tính toán rating mới
      final int reviewCount = allRatings.length;
      final double avgRating = reviewCount == 0 
          ? 0.0 
          : allRatings.reduce((a, b) => a + b) / reviewCount;

      // 4. Cập nhật lại document khách sạn
      transaction.update(_hotelDoc(review.hotelId), {
        'avgRating': avgRating,
        'reviewCount': reviewCount,
      });
    });
  }
}