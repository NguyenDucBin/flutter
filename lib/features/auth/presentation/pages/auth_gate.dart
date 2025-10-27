import 'package:doanflutter/features/auth/presentation/pages/sign_in_page.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
// 🎯 THAY ĐỔI IMPORT Ở ĐÂY
import 'package:doanflutter/features/home/presentation/pages/user_home_page.dart'; // Trang chính User
import 'package:doanflutter/features/home/presentation/pages/admin_home_page.dart';// Trang chính Admin
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authService.user == null) {
      return const SignInPage();
    }

    // 🎯 THAY ĐỔI ĐIỀU HƯỚNG Ở ĐÂY
    if (authService.user!.role == 'admin') {
      return const AdminHomePage(); // Điều hướng đến trang chính của Admin
    } else {
      return const UserHomePage(); // Điều hướng đến trang chính của User
    }
  }
}