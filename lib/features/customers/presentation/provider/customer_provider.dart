// lib/features/customers/presentation/provider/customer_provider.dart
import 'package:flutter/foundation.dart';
import 'package:doanflutter/features/customers/domain/entities/customer_entity.dart';
import 'package:doanflutter/features/customers/domain/repositories/customer_repository.dart';
// --- THÊM IMPORT NÀY ---
import 'package:doanflutter/features/customers/data/models/customer_model.dart'; 

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository;
  CustomerProvider(this._customerRepository);

  List<CustomerEntity> _customers = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;
  String? _deleteError;
  String? get deleteError => _deleteError;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;
  String? _updateError;
  String? get updateError => _updateError;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CustomerEntity> get filteredCustomers {
    if (_searchQuery.isEmpty) {
      return _customers;
    }
    return _customers.where((c) {
      final nameLower = c.name.toLowerCase();
      final emailLower = c.email.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower) || emailLower.contains(queryLower);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

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

  Future<void> deleteCustomer(String customerId) async {
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _customerRepository.deleteCustomer(customerId);
      _customers.removeWhere((customer) => customer.id == customerId);
    } catch (e) {
      _deleteError = e.toString();
      throw Exception(_deleteError);
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomer(CustomerEntity customer) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      await _customerRepository.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        // --- SỬA LỖI Ở DÒNG NÀY ---
        // Gán CustomerModel (con) thay vì CustomerEntity (cha)
        _customers[index] = CustomerModel.fromEntity(customer);
      }
    } catch (e) {
      _updateError = e.toString();
      throw Exception(_updateError);
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}