import 'package:flutter/foundation.dart';
import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';
import 'package:doanflutter/features/customers/domain/repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository;
  CustomerProvider(this._customerRepository);

  List<CustomerEntity> _customers = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters cho UI
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter cho danh sách đã lọc (UI sẽ dùng cái này)
  List<CustomerEntity> get filteredCustomers {
    if (_searchQuery.isEmpty) {
      return _customers;
    }
    return _customers.where((c) {
      final nameLower = c.name.toLowerCase();
      final emailLower = c.email.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      // Lọc theo tên hoặc email (giống code cũ của bạn)
      return nameLower.contains(queryLower) || emailLower.contains(queryLower);
    }).toList();
  }

  // Action: Cập nhật thanh tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Action: Tải dữ liệu từ Repository
  Future<void> fetchCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _customers = await _customerRepository.fetchCustomers();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}