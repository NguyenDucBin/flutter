// lib/features/booking/presentation/pages/booking_list_page.dart
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:doanflutter/features/reviews/domain/entities/review_entity.dart';
import 'package:doanflutter/features/reviews/presentation/provider/review_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
          return Column( // 👈 BỌC BookingCard TRONG COLUMN
            children: [
              BookingCard(booking: booking),
              // 👇--- THÊM NÚT ĐÁNH GIÁ NẾU ĐÃ CHECK-OUT ---
              if (booking.status == 'checked_out')
                _buildReviewButton(context, booking, user),
              // ----------------------------------------
            ],
          );
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
  //review button
  Widget _buildReviewButton(BuildContext context, dynamic booking, dynamic user) {
    return Container( 
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        )
      ),
      child: TextButton.icon(
        icon: const Icon(Icons.star, color: Colors.amber),
        label: const Text('Viết đánh giá', style: TextStyle(color: Colors.black87)),
        onPressed: () {
          // Mở Dialog để đánh giá
          _showReviewDialog(context, booking, user);
        },
      ),
    );
  }
  //review dialog
  void _showReviewDialog(BuildContext context, dynamic booking, dynamic user) {
    double _rating = 3.0; // Điểm sao mặc định
    final _commentController = TextEditingController();
    final reviewProvider = context.read<ReviewProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép keyboard đẩy bottom sheet lên
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Đánh giá của bạn cho "${booking.hotelName}"', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  _rating = rating; // Cập nhật điểm sao
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: 'Viết bình luận...'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Gửi đánh giá'),
                onPressed: () async {
                  final review = ReviewEntity(
                    hotelId: booking.hotelId,
                    userId: user.uid,
                    userName: user.name ?? 'Ẩn danh',
                    rating: _rating,
                    comment: _commentController.text,
                    createdAt: DateTime.now(),
                  );
                  try {
                    await reviewProvider.submitReview(review);
                    Navigator.pop(ctx); // Đóng bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
                    );
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}'))
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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