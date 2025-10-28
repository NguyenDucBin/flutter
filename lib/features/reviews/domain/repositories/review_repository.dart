import 'package:doanflutter/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  // Lấy tất cả review của 1 khách sạn
  Future<List<ReviewEntity>> getReviewsForHotel(String hotelId);
  // Gửi 1 review mới
  Future<void> submitReview(ReviewEntity review);
}