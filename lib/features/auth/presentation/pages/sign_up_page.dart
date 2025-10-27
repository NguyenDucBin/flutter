import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';

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
  final _confirmController = TextEditingController();
  String _selectedRole = 'customer';
  bool _obscure = true;

  String _formatError(Object e) {
    final msg = e.toString();
    if (msg.contains('email-already-in-use')) return 'Email đã được sử dụng';
    if (msg.contains('weak-password')) return 'Mật khẩu quá yếu';
    return 'Đăng ký thất bại. Vui lòng thử lại';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authService = context.read<AuthService>();
    try {
      await authService.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );
      // AuthGate sẽ điều hướng
    } catch (e) {
      final message = _formatError(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

  String? _validateConfirm(String? v) {
    if (v != _passwordController.text) return 'Mật khẩu không khớp';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const FlutterLogo(size: 80),
                const SizedBox(height: 16),
                const Text('Tạo tài khoản mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Vui lòng nhập thông tin để đăng ký', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: _validateConfirm,
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Bạn là',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'customer', child: Text('Khách hàng')),
                          DropdownMenuItem(value: 'admin', child: Text('Chủ khách sạn (Admin)')),
                        ],
                        onChanged: (v) { if (v != null) setState(() => _selectedRole = v); },
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity, 
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authService.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authService.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                    backgroundColor: Colors.indigo,
                                  ),
                                )
                              : const Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Đã có tài khoản?'),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đăng nhập'),
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