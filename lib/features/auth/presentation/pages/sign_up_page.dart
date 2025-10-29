// lib/features/auth/presentation/pages/sign_up_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseException

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Controller for confirmation
  // String _selectedRole = 'customer'; // <-- ĐÃ XÓA
  bool _obscurePassword = true; // State for password visibility
  bool _obscureConfirmPassword = true; // State for confirm password visibility

  // Improved error handling for sign-up
  String _formatError(Object e) {
    if (e is FirebaseException) { // Catch specific Firebase errors
      switch (e.code) {
        case 'email-already-in-use':
          return 'Địa chỉ email này đã được sử dụng.';
        case 'weak-password':
          return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        case 'invalid-email':
          return 'Địa chỉ email không hợp lệ.';
        // Add other relevant Firebase Auth error codes here
        default:
          return 'Đăng ký thất bại: (${e.code})'; // Consider logging e.message
      }
    }
    // For non-Firebase errors
    return 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
  }

  Future<void> _submit() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return; // Validate form

    final authService = context.read<AuthService>();
    try {
      // --- SỬA Ở ĐÂY: Bỏ _selectedRole ---
      await authService.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        // _selectedRole, // <-- ĐÃ XÓA
      );
      // AuthGate will handle navigation after successful sign-up
      if (mounted) {
         // Optionally show a success message before AuthGate navigates
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Đăng ký thành công! Đang chuyển hướng...')),
         );
         // No need to manually navigate here if AuthGate is listening correctly
      }
    } catch (e) {
      final message = _formatError(e); // Get user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent, // Error color
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose the confirm controller too
    super.dispose();
  }

  // Name validation
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  // Email validation (same as SignInPage)
  String? _validateEmail(String? value) {
     if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Địa chỉ email không hợp lệ';
    }
    return null;
  }

  // Password validation (same as SignInPage, maybe add complexity later)
  String? _validatePassword(String? value) {
     if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    // Optional: Add complexity checks (uppercase, number, symbol)
    return null;
  }

  // Confirm password validation
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context); // Get theme data

    return Scaffold(
      // Keep AppBar for navigation back
      appBar: AppBar(
        title: const Text('Tạo tài khoản'),
        elevation: 0, // Remove shadow
        backgroundColor: Colors.transparent, // Transparent AppBar
        foregroundColor: theme.primaryColor, // Back button color
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Adjust vertical padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Logo ---
                  Image.asset(
                    'assets/images/anhbooking.png', // **MAKE SURE THE PATH IS CORRECT**
                    height: 100, // Slightly smaller logo for sign up?
                  ),
                  const SizedBox(height: 24),

                  // --- Title Text ---
                  Text(
                    'Bắt đầu hành trình!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Điền thông tin để tạo tài khoản mới',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Sign Up Form ---
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Name Field ---
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Họ và tên',
                            prefixIcon: Icon(Icons.person_outline, color: theme.primaryColor.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: _validateName,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),

                        // --- Email Field ---
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'your.email@example.com',
                            prefixIcon: Icon(Icons.alternate_email, color: theme.primaryColor.withOpacity(0.7)),
                             border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: _validateEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),

                        // --- Password Field ---
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor.withOpacity(0.7)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                             border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: _validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),

                        // --- Confirm Password Field ---
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword, // Separate state
                           decoration: InputDecoration(
                            labelText: 'Xác nhận mật khẩu',
                            prefixIcon: Icon(Icons.lock_reset_outlined, color: theme.primaryColor.withOpacity(0.7)), // Different icon
                             suffixIcon: IconButton( // Visibility toggle for confirm field
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: _validateConfirmPassword, // Use confirm password validator
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 16),

                         // --- Role Selection --- (ĐÃ BỊ XÓA)
                         // DropdownButtonFormField<String>( ... ),
                        
                        const SizedBox(height: 24), // Spacing before button

                        // --- Sign Up Button ---
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authService.isLoading ? null : _submit,
                             style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              elevation: 3,
                            ),
                            child: authService.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Đăng ký'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Login Link ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        // Go back to the previous screen (SignInPage)
                        onPressed: () => Navigator.pop(context),
                         style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Đăng nhập ngay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}