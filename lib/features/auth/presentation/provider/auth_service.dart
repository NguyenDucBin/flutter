// lib/features/auth/presentation/provider/auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doanflutter/features/auth/domain/entities/user_entity.dart';
import 'package:doanflutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:doanflutter/features/favorites/presentation/provider/favorites_provider.dart';
import 'package:doanflutter/core/services/messaging_service.dart'; 
import 'package:provider/provider.dart';

// AuthService bây giờ là Provider quản lý trạng thái,
// nó sử dụng AuthRepository để thực hiện hành động.
class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  final MessagingService _messagingService;
  StreamSubscription<UserEntity?>? _userSubscription;

  UserEntity? _user;
  UserEntity? get user => _user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Constructor: Lắng nghe stream từ Repository
  AuthService(this._authRepository, this._messagingService) { 
    _userSubscription = _authRepository.user.listen(
      (user) {
        _user = user;
        _isLoading = false;
        _error = null;
        notifyListeners();

        if (user != null) {
          // Khi user đăng nhập, lấy FcmToken
          try {
            _messagingService.initAndSaveToken();
          } catch (e) {
            debugPrint("Lỗi khi gọi initAndSaveToken: $e");
          }
        }
      },
      onError: (e) {
        _user = null;
        _isLoading = false;
        _error = "Đã xảy ra lỗi: $e";
        notifyListeners();
      },
    );
  }

  // Hàm Đăng nhập
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepository.signIn(email: email, password: password);
      // Stream sẽ tự động cập nhật, ta không cần làm gì thêm
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      // Ném lỗi ra để UI (SignInPage) có thể bắt và hiển thị SnackBar
      throw Exception(_error);
    }
  }

  // --- SỬA HÀM NÀY: Bỏ tham số 'role' ---
  // Hàm Đăng ký
  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        // role: role, // <-- ĐÃ XÓA
      );
      // Stream sẽ tự động cập nhật
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception(_error);
    }
  }

  // Hàm Đăng xuất
  Future<void> signOut() async {
    await _authRepository.signOut();
    // Stream sẽ tự động cập nhật
  }

  // Hủy lắng nghe stream khi Provider bị hủy
  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}