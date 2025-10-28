import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/reviews/data/models/review_model.dart';
import 'package:doanflutter/features/reviews/domain/entities/review_entity.dart';
import 'package:doanflutter/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _db;
  ReviewRepositoryImpl(this._db);

  // Cấu trúc: /hotels/{hotelId}/reviews/{reviewId}
  CollectionReference _reviewsCol(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('reviews');

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
      createdAt: DateTime.now(), // Ghi đè thời gian lúc tạo
    );
    // Lưu ý: Cần thêm logic kiểm tra xem user này đã review khách sạn này chưa
    // Tạm thời cho phép review nhiều lần
    await _reviewsCol(review.hotelId).add(model.toMap());
  }
}