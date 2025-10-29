import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:doanflutter/features/reviews/domain/entities/review_entity.dart';
import 'package:doanflutter/features/reviews/presentation/provider/review_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/booking_card_widget.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

// Thêm 'with SingleTickerProviderStateMixin'
class _BookingListPageState extends State<BookingListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController; // Thêm controller cho TabBar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Khởi tạo TabController với 3 tab

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().user;
      if (user != null) {
        // Vẫn gọi fetchMyBookings như cũ để lấy dữ liệu ban đầu
        context.read<BookingProvider>().fetchMyBookings(user.uid);
      }
    });
  }

  // Thêm hàm dispose để hủy TabController
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Sửa lại hàm build để dùng AppBar có TabBar
  @override
  Widget build(BuildContext context) {
    // Không cần watch ở đây vì _buildBody đã watch rồi
    // final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyến đi của tôi',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
        // Thêm TabBar vào bottom của AppBar
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã qua'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF4F6F9),
      // Sửa body để gọi hàm _buildBody
      body: _buildBody(context, context.watch<BookingProvider>()), // Gọi hàm _buildBody và truyền provider đã watch
    );
  }

  // Sửa _buildBody để dùng TabBarView
  Widget _buildBody(BuildContext context, BookingProvider provider) {
    final user = context.watch<AuthService>().user; // Lấy user

    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập.'));
    }
    // Sử dụng isLoadingList (trạng thái chung khi fetch)
    if (provider.isLoadingList) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text('Lỗi: ${provider.error}'));
    }

    // Thêm TabBarView để hiển thị nội dung từng tab
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab "Sắp tới" - Thêm showCancelButton: true
        _buildBookingTab(
          context,
          provider.upcomingBookings,
          user,
          'Chưa có chuyến đi nào sắp tới.',
          showCancelButton: true, // <<< THÊM DÒNG NÀY
        ),
        // Tab "Đã qua" - dùng getter completedBookings VÀ HÀM MỚI
        _buildCompletedBookingTab( // Giữ nguyên hàm này
          context,
          provider.completedBookings,
          user,
          'Bạn chưa hoàn thành chuyến đi nào.',
        ),

        // Tab "Đã hủy" - dùng getter cancelledBookings
        _buildBookingTab( // Giữ nguyên hàm này
          context,
          provider.cancelledBookings,
          user,
          'Không có chuyến đi nào bị hủy.',
          // Không cần nút hủy ở đây
        ),
      ],
    );
  }

  // Tách ra hàm mới: _buildBookingTab để tái sử dụng code cho mỗi tab
  // --- THÊM THAM SỐ showCancelButton ---
  Widget _buildBookingTab(BuildContext context, List<BookingEntity> bookings,
      dynamic user, String emptyMessage, { bool showCancelButton = false }) { // Thêm tham số
    if (bookings.isEmpty) {
      // Dùng hàm empty state với message tùy chỉnh
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Gọi lại fetchMyBookings khi kéo refresh
        if (user != null) {
          await context.read<BookingProvider>().fetchMyBookings(user.uid);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Column(
            children: [
              // Thêm GestureDetector để cho phép nhấn vào xem chi tiết (TODO)
              GestureDetector(
                  onTap: () {
                    // TODO: Điều hướng đến trang chi tiết booking
                    // Navigator.pushNamed(context, '/booking_detail', arguments: booking.bookingId);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Xem chi tiết cho: ${booking.hotelName}')));
                  },
                  child: BookingCard(booking: booking)
              ),
              // --- THÊM PHẦN NÚT HỦY ---
              if (showCancelButton && (booking.status == 'pending' || booking.status == 'confirmed')) // Chỉ hiện nút Hủy ở tab "Sắp tới" và cho các trạng thái phù hợp
                Container(
                  width: double.infinity, // Cho nút chiếm hết chiều rộng
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                     borderRadius: const BorderRadius.only(
                       bottomLeft: Radius.circular(12),
                       bottomRight: Radius.circular(12),
                     )
                  ),
                  child: TextButton.icon(
                    icon: Icon(Icons.cancel_outlined, color: Colors.red[700]),
                    label: Text(
                      'Hủy phòng',
                       style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _confirmCancellation(context, booking, user), // Gọi hàm xác nhận hủy
                  ),
                ),
              // -----------------------
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }

  // --- THÊM HÀM XÁC NHẬN HỦY ---
  Future<void> _confirmCancellation(BuildContext context, BookingEntity booking, dynamic user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận hủy'),
          content: Text('Bạn có chắc chắn muốn hủy đặt phòng tại "${booking.hotelName}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Trả về false
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hủy phòng'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Trả về true
              },
            ),
          ],
        );
      },
    );

    // Nếu người dùng xác nhận (confirmed == true)
    if (confirmed == true && booking.bookingId != null) {
      try {
        // Gọi provider để hủy
        await context.read<BookingProvider>().cancelBookingByUser(booking.bookingId!, user.uid);
        // Kiểm tra mounted trước khi dùng context trong async gap
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã hủy đặt phòng thành công.'), backgroundColor: Colors.orange),
           );
        }
      } catch (e) {
         // Kiểm tra mounted trước khi dùng context trong async gap
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
            );
         }
      }
    }
  }
  // ---------------------------

  // Hàm này dành riêng cho tab "Đã qua"
  Widget _buildCompletedBookingTab(BuildContext context,
      List<BookingEntity> bookings, dynamic user, String emptyMessage) {
    if (bookings.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (user != null) {
          await context.read<BookingProvider>().fetchMyBookings(user.uid);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Column(
            children: [
              GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Xem chi tiết cho: ${booking.hotelName}')));
                  },
                  child: BookingCard(booking: booking)),

              // SỬA ĐỔI: Luôn hiển thị nút review vì đây là tab "Đã qua"
              _buildReviewButton(context, booking, user),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }

  // Sửa lại _buildEmptyState để nhận message
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.luggage_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message, // Dùng message truyền vào
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54),
            textAlign: TextAlign.center,
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

  // (Hàm _buildReviewButton và _showReviewDialog giữ nguyên từ file bạn cung cấp)
  //review button
  Widget _buildReviewButton(
      BuildContext context, dynamic booking, dynamic user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )),
      child: TextButton.icon(
        icon: const Icon(Icons.star, color: Colors.amber),
        label:
            const Text('Viết đánh giá', style: TextStyle(color: Colors.black87)),
        onPressed: () {
          _showReviewDialog(context, booking, user);
        },
      ),
    );
  }

  //review dialog
  void _showReviewDialog(BuildContext context, dynamic booking, dynamic user) {
    double _rating = 3.0;
    final _commentController = TextEditingController();
    // Đọc ReviewProvider một lần ở đây
    final reviewProvider = context.read<ReviewProvider>();
    // Đọc HotelProvider một lần ở đây
    final hotelProvider = context.read<HotelProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) { // ctx là context của bottom sheet
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
              Text('Đánh giá của bạn cho "${booking.hotelName}"',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration:
                    const InputDecoration(labelText: 'Viết bình luận...'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Gửi đánh giá'),
                onPressed: () async {
                  final review = ReviewEntity(
                    hotelId: booking.hotelId,
                    userId: user.uid,
                    userName: user.name ?? 'Ẩn danh', // Lấy tên user từ Auth
                    rating: _rating,
                    comment: _commentController.text,
                    createdAt: DateTime.now(),
                  );
                  try {
                    await reviewProvider.submitReview(review);
                    Navigator.pop(ctx); // Đóng bottom sheet dùng ctx
                    // Sau khi gửi review, gọi fetchAllHotels để cập nhật rating trung bình
                    await hotelProvider.fetchAllHotels();
                    // Kiểm tra mounted trước khi dùng context bên ngoài
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')),
                       );
                    }
                  } catch (e) {
                     // Kiểm tra mounted trước khi dùng context bên ngoài
                     if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Lỗi: ${e.toString()}')));
                     }
                     // Có thể không cần pop ở đây nếu muốn giữ dialog mở khi lỗi
                     // Navigator.pop(ctx);
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
}