// lib/features/booking/presentation/pages/booking_list_page.dart
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm import này
import 'package:provider/provider.dart';
// Import file widget mới (bạn cần tạo file này)
import '../widgets/booking_card_widget.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().user;
      if (user != null) {
        context.read<BookingProvider>().fetchMyBookings(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phòng Đã Đặt', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F6F9),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () {
          // --- SỬA Ở ĐÂY ---
          // Điều hướng đến trang danh sách khách sạn (ví dụ: route '/home')
          Navigator.pushNamed(context, '/home');
          // ------------------
        },
        // --- SỬA Ở ĐÂY ---
        icon: const Icon(Icons.search), // Đổi icon thành tìm kiếm
        label: const Text('Tìm & Đặt Phòng'), // Đổi chữ cho rõ nghĩa
        // ------------------
      ),
      body: _buildBody(context, user, bookingProvider),
    );
  }

  Widget _buildBody(BuildContext context, dynamic user, BookingProvider provider) {
    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập.'));
    }
    if (provider.isLoadingList) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text('Lỗi: ${provider.error}'));
    }
    if (provider.myBookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthService>().user;
        if (user != null) {
          await context.read<BookingProvider>().fetchMyBookings(user.uid);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: provider.myBookings.length,
        itemBuilder: (context, index) {
          final booking = provider.myBookings[index];
          return BookingCard(booking: booking);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.luggage_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có đặt phòng nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Các phòng bạn đặt sẽ xuất hiện ở đây.',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Color _statusColor(String status) {
     switch (status) {
       case 'pending': return Colors.orange.shade600;
       case 'confirmed': return Colors.green.shade600;
       case 'canceled': return Colors.red.shade600;
       default: return Colors.grey.shade600;
     }
   }
}