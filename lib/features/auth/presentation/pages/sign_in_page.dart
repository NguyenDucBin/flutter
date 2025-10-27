import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  String _formatError(Object e) {
    final msg = e.toString();
    // Nếu repository đã trả về message thân thiện thì hiển thị trực tiếp
    if (msg.contains('firebase_auth')) {
      return 'Đăng nhập thất bại. Vui lòng kiểm tra email/mật khẩu.';
    }
    return msg;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authService = context.read<AuthService>();
    try {
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // AuthGate sẽ điều hướng tự động
    } catch (e) {
      final message = _formatError(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
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

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!regex.hasMatch(v.trim())) return 'Email không hợp lệ';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu phải >= 6 ký tự';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Logo (thay bằng Image.asset nếu có)
                const FlutterLogo(size: 80),
                const SizedBox(height: 16),
                const Text('Chào mừng trở lại', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Đăng nhập để tiếp tục', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authService.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white, // Thêm màu chữ trắng
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500, // Làm đậm chữ
                            ),
                            elevation: 2, // Thêm độ nổi cho button
                          ),
                          child: authService.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white, // Spinner màu trắng
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    color: Colors.white, // Đảm bảo chữ luôn trắng
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Chưa có tài khoản?'),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                            child: const Text('Đăng ký'),
                          ),
                        ],
                      ),
                      if (authService.error != null) ...[
                        const SizedBox(height: 8),
                        Text(authService.error!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}