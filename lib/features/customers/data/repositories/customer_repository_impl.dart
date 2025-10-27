import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/customers/data/models/customer_model.dart';
import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';
import 'package:doanflutter/features/customers/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FirebaseFirestore _db;
  CustomerRepositoryImpl(this._db);

  @override
  Future<List<CustomerEntity>> fetchCustomers() async {
    // Truy vấn collection 'users' và lọc theo vai trò 'customer'
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .get();

    // Chuyển đổi kết quả về list Entity
    return snapshot.docs.map((doc) => CustomerModel.fromSnapshot(doc)).toList();
  }
}