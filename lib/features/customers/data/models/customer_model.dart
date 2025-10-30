import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
  });

  // Chuyển đổi từ Firestore Document ('users' collection) về Model
  factory CustomerModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return CustomerModel(
      id: snap.id, // snap.id chính là uid
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '', // Giả sử bạn lưu phone trong 'users'
    );
  }

  // --- HÀM NÀY BỊ THIẾU (Gây ra lỗi TypeError) ---
  // Chuyển từ Entity (lớp cha) sang Model (lớp con)
  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
    );
  }

  // --- HÀM NÀY BỊ THIẾU (Cần thiết cho việc update) ---
  // Chuyển Model thành Map để update lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}