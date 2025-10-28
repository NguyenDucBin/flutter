import 'package:flutter/foundation.dart';
import 'package:doanflutter/features/reviews/domain/entities/review_entity.dart';
import 'package:doanflutter/features/reviews/domain/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _reviewRepository;
  ReviewProvider(this._reviewRepository);

  List<ReviewEntity> _reviews = [];
  List<ReviewEntity> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchReviews(String hotelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _reviews = await _reviewRepository.getReviewsForHotel(hotelId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitReview(ReviewEntity review) async {
    // Không cần isLoading, vì nó là một hành động nhanh
    try {
      await _reviewRepository.submitReview(review);
      // Thêm review mới vào đầu danh sách UI
      _reviews.insert(0, review);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception(e); // Ném lỗi để UI (Dialog) bắt
    }
  }
}