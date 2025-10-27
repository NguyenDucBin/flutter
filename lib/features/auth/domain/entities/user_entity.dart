import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? name;
  final String role; // 'customer' hoặc 'admin'

  const UserEntity({
    required this.uid,
    this.email,
    this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [uid, email, name, role];
}