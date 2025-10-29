// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:doanflutter/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:doanflutter/features/auth/domain/entities/user_entity.dart';
import 'package:doanflutter/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<UserEntity?> get user {
    // Luồng này phức tạp:
    // 1. Lắng nghe thay đổi từ Auth (userStream)
    // 2. Khi có user, dùng 'asyncMap' để gọi Firestore (getUserRole)
    // 3. Trả về UserEntity hoàn chỉnh
    return _dataSource.userStream.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null; // Không có ai đăng nhập
      }

      // Lấy vai trò (role) từ Firestore
      final role = await _dataSource.getUserRole(firebaseUser.uid);

      // Trả về UserEntity hoàn chỉnh
      return UserEntity(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        name: firebaseUser.displayName, // (Bạn có thể cập nhật name khi đăng ký)
        role: role ?? 'customer', // Mặc định là 'customer' nếu có lỗi
      );
    });
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _dataSource.signIn(email: email, password: password);
  }

  // --- SỬA HÀM NÀY: Bỏ tham số 'role' ---
  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    // required String role, // <-- ĐÃ XÓA
  }) {
    return _dataSource.signUp(
      name: name,
      email: email,
      password: password,
      // role: role, // <-- ĐÃ XÓA
    );
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}