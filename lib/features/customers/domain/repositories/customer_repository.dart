// lib/features/customers/domain/repositories/customer_repository.dart
import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';

abstract class CustomerRepository {
  // Hợp đồng: Lấy danh sách tất cả người dùng có vai trò 'customer'
  Future<List<CustomerEntity>> fetchCustomers();

  // --- THÊM MỚI ---
  // Hợp đồng: Xóa một khách hàng
  Future<void> deleteCustomer(String customerId);

  // --- THÊM MỚI ---
  // Hợp đồng: Cập nhật thông tin khách hàng
  Future<void> updateCustomer(CustomerEntity customer);
}