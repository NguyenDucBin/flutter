  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:doanflutter/features/customers/data/models/customer_model.dart';
  import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';
  import 'package:doanflutter/features/customers/domain/repositories/customer_repository.dart';

  class CustomerRepositoryImpl implements CustomerRepository {
    final FirebaseFirestore _db;
    CustomerRepositoryImpl(this._db);

    // Helper để lấy collection 'users'
    CollectionReference get _usersCol => _db.collection('users');

    @override
    Future<List<CustomerEntity>> fetchCustomers() async {
      // Truy vấn collection 'users' và lọc theo vai trò 'customer'
      final snapshot = await _usersCol
          .where('role', isEqualTo: 'customer')
          .get();

      // --- SỬA LỖI Ở ĐÂY ---
      // Chuyển đổi kết quả về list Model, sau đó ép kiểu rõ ràng về List<CustomerEntity>
      final customerModels = snapshot.docs.map((doc) => CustomerModel.fromSnapshot(doc)).toList();
      
      // Trả về kiểu List<CustomerEntity>
      return customerModels;
    }

    @override
    Future<void> deleteCustomer(String customerId) async {
      try {
        await _usersCol.doc(customerId).delete();
      } catch (e) {
        // Ném lỗi để Provider xử lý
        throw Exception('Lỗi khi xóa khách hàng: $e');
      }
    }

    @override
    Future<void> updateCustomer(CustomerEntity customer) async {
      try {
        // Chuyển Entity sang Model để dùng hàm toMap()
        // Dòng này đã được sửa ở lần trước và đã đúng
        final customerModel = CustomerModel.fromEntity(customer);
        await _usersCol.doc(customer.id).update(customerModel.toMap());
      } catch (e) {
        // Ném lỗi để Provider xử lý
        throw Exception('Lỗi khi cập nhật khách hàng: $e');
      }
    }
  }