import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone; // <-- Thêm 'phone' vì file UI của bạn có dùng

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, phone];
}