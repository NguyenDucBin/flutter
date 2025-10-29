// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:doanflutter/features/auth/domain/entities/user_entity.dart';

// Đây là "hợp đồng" (contract) cho tầng Data
abstract class AuthRepository {
  // Trả về một Stream real-time cho biết người dùng hiện tại là ai
  Stream<UserEntity?> get user;

  // Đăng nhập
  Future<void> signIn({required String email, required String password});

  // --- SỬA HÀM NÀY: Bỏ tham số 'role' ---
  // Đăng ký (quan trọng: truyền cả 'name' và 'role')
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    // required String role, // <-- ĐÃ XÓA
  });

  // Đăng xuất
  Future<void> signOut();
}