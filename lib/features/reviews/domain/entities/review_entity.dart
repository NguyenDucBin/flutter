import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String? id;
  final String hotelId;
  final String userId;
  final String userName; // Lưu tên user để hiển thị
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    this.id,
    required this.hotelId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, hotelId, userId, userName, rating, comment, createdAt];
}