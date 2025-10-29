import 'package:doanflutter/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:doanflutter/features/auth/domain/entities/user_entity.dart';
import 'package:doanflutter/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<UserEntity?> get user {
    return _dataSource.userStream.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null; // Không có ai đăng nhập
      }

      // Lấy dữ liệu (name, role) từ Firestore bằng hàm mới
      final userData = await _dataSource.getUserData(firebaseUser.uid);

      // Trả về UserEntity hoàn chỉnh
      return UserEntity(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        // DÙNG userData?['name']
        name: userData?['name'] ?? firebaseUser.displayName, 
        // DÙNG userData?['role']
        role: userData?['role'] ?? 'customer', 
      );
    });
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return _dataSource.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}