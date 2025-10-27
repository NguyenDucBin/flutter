import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';

abstract class CustomerRepository {
  // Hợp đồng: Lấy danh sách tất cả người dùng có vai trò 'customer'
  Future<List<CustomerEntity>> fetchCustomers();

  // (Bạn có thể thêm các hàm deleteCustomer, updateCustomer... ở đây)
}