import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    super.id,
    required super.hotelId,
    required super.userId,
    required super.userName,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return ReviewModel(
      id: snap.id,
      hotelId: data['hotelId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Người dùng ẩn',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}