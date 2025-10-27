import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseException

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // State variable for password visibility

  // Improved error handling
  String _formatError(Object e) {
    if (e is FirebaseException) { // Catch specific Firebase errors
      switch (e.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này.';
        case 'wrong-password':
          return 'Mật khẩu không chính xác. Vui lòng thử lại.';
        case 'invalid-email':
          return 'Địa chỉ email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        case 'too-many-requests':
          return 'Quá nhiều yêu cầu đăng nhập. Vui lòng thử lại sau.';
        // Add other relevant Firebase Auth error codes here
        default:
          // For other Firebase errors, show a generic message or e.message
          return 'Lỗi đăng nhập: (${e.code})'; // Consider logging e.message for debugging
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
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Navigation is handled by AuthGate
    } catch (e) {
      final message = _formatError(e); // Get user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent, // Error color
            behavior: SnackBarBehavior.floating, // Make it float
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    // Simple regex for email format validation
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Địa chỉ email không hợp lệ';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    // Optional: Add minimum length check
    // if (value.length < 6) {
    //   return 'Mật khẩu phải có ít nhất 6 ký tự';
    // }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context); // Get theme data

    return Scaffold(
      // Remove AppBar for a cleaner look
      // appBar: AppBar(title: const Text('Đăng nhập')),
      body: SafeArea( // Ensure content is not under status bar/notches
        child: Center(
          child: ConstrainedBox( // Limit width on larger screens
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView( // Allow scrolling when keyboard appears
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Make children stretch horizontally
                children: [
                  // --- Logo ---
                  Image.asset(
                    'assets/images/anhbooking.png', // **MAKE SURE THE PATH AND FILENAME ARE CORRECT**
                    height: 120, // Adjust height as needed
                     width: 150, // Optionally set width
                  ),
                  const SizedBox(height: 32),

                  // --- Welcome Text ---
                  Text(
                    'Chào mừng bạn!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor, // Use primary color
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng nhập để khám phá khách sạn mơ ước',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40), // Increased spacing before form

                  // --- Login Form ---
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user types
                        ),
                        const SizedBox(height: 16),

                        // --- Password Field ---
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, // Use state variable
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: Icon(Icons.lock_outline, color: theme.primaryColor.withOpacity(0.7)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword; // Toggle visibility
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          validator: _validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user types
                        ),
                        // --- Forgot Password ---
                         Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: Align(
                             alignment: Alignment.centerRight,
                             child: TextButton(
                               onPressed: () {
                                 // TODO: Implement forgot password functionality
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text('Chức năng quên mật khẩu chưa được thêm.')),
                                 );
                               },
                               style: TextButton.styleFrom(
                                 padding: EdgeInsets.zero,
                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                               ),
                               child: Text(
                                 'Quên mật khẩu?',
                                 style: TextStyle(color: theme.primaryColor),
                               ),
                             ),
                           ),
                         ),
                        const SizedBox(height: 24), // Spacing before button

                        // --- Login Button ---
                        SizedBox(
                          height: 50, // Button height
                          child: ElevatedButton(
                            onPressed: authService.isLoading ? null : _submit, // Disable button when loading
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor, // Use theme primary color
                              foregroundColor: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0), // Rounded corners
                              ),
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                              elevation: 3, // Slight shadow
                            ),
                            child: authService.isLoading
                                ? const SizedBox( // Loading indicator inside button
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white, // White spinner
                                    ),
                                  )
                                : const Text('Đăng nhập'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Sign Up Link ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0), // Minimal padding
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor, // Use primary color for link
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