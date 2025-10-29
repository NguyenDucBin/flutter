// lib/features/hotel/presentation/pages/hotel_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
// RoomEntity không cần import trực tiếp nữa
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';
// BookingScreen sẽ được gọi qua Navigator.pushNamed
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:doanflutter/features/reviews/presentation/provider/review_provider.dart';

// --- THÊM IMPORT CHO ROOMCARD MỚI ---
import 'package:doanflutter/features/rooms/presentation/widgets/room_card_widget.dart';
import 'package:doanflutter/features/favorites/presentation/provider/favorites_provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelEntity hotel;
  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  late DateTime _checkIn;
  late DateTime _checkOut;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _checkIn = DateTime(now.year, now.month, now.day); // Bắt đầu từ 0h hôm nay
    _checkOut = _checkIn.add(const Duration(days: 1)); // Mặc định 1 đêm

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tải phòng và review cho khách sạn này
      // Tạm thời vẫn gọi fetchRooms, Giai đoạn 3 sẽ đổi sang fetchAvailableRooms
      context.read<RoomProvider>().fetchAvailableRooms(
            widget.hotel.id,
            _checkIn,
            _checkOut,
          );
      context.read<ReviewProvider>().fetchReviews(widget.hotel.id);
    });
  }

  // Danh sách tiện ích và icon tương ứng (giống AddEditHotelPage)
  final Map<String, IconData> _allAmenities = {
    'Wifi': Icons.wifi,
    'Hồ bơi': Icons.pool,
    'Bãi đỗ xe': Icons.local_parking,
    'Nhà hàng': Icons.restaurant,
    'Gym': Icons.fitness_center,
    'Spa': Icons.spa,
  };

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final now = DateTime.now();
    // Ngày đầu tiên có thể chọn: hôm nay cho check-in, ngày sau check-in cho check-out
    final firstDate = isCheckIn ? DateTime(now.year, now.month, now.day) : _checkIn.add(const Duration(days: 1));
    final initialDate = isCheckIn ? _checkIn : _checkOut;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)), // Cho phép đặt trước 1 năm
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          // Đảm bảo ngày check-out luôn sau ngày check-in ít nhất 1 ngày
          if (!_checkOut.isAfter(_checkIn)) {
            _checkOut = _checkIn.add(const Duration(days: 1));
          }
        } else {
          _checkOut = picked;
        }
      });
      context.read<RoomProvider>().fetchAvailableRooms(
            widget.hotel.id,
            _checkIn,
            _checkOut,
          );
      print('Ngày đã chọn: Check-in: $_checkIn, Check-out: $_checkOut'); // Debug
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final dateFormat = DateFormat('EEE, dd MMM', 'vi_VN'); // Định dạng Thứ, Ngày Tháng (Tiếng Việt)
    final theme = Theme.of(context); // Lấy theme
    final favoritesProvider = context.watch<FavoritesProvider>();
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final bool isFavorite = favoritesProvider.isFavorite(widget.hotel.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.name),
        backgroundColor: Colors.indigo, // Màu nhất quán
        foregroundColor: Colors.white, // Màu chữ
        actions: [
          if (user != null) // Chỉ hiện nếu đã đăng nhập
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : Colors.white,
              ),
              onPressed: () {
                favoritesProvider.toggleFavorite(user.uid, widget.hotel.id);
              },
            ),
        ],
      ),
      body: ListView( // Dùng ListView thay vì SingleChildScrollView
        children: [
          // --- Phần Ảnh Khách sạn (PageView) ---
          if (widget.hotel.imageUrls.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: widget.hotel.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.hotel.imageUrls[index],
                    fit: BoxFit.cover,
                    // Widget hiển thị khi đang tải ảnh
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    // Widget hiển thị khi lỗi tải ảnh
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 50)),
                    ),
                  );
                },
              ),
            )
          else // Ảnh placeholder nếu không có ảnh
            Container(
              height: 250,
              color: Colors.grey[200],
              child: Icon(Icons.business_outlined, size: 100, color: Colors.grey[400]),
            ),

          // --- Phần Thông tin Khách sạn ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.name,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row( // Địa chỉ với icon
                   children: [
                     Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
                     const SizedBox(width: 4),
                     Expanded( // Cho phép địa chỉ dài xuống dòng
                       child: Text(
                         widget.hotel.address,
                         style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                       ),
                     ),
                   ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Mô tả',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.hotel.description.isNotEmpty ? widget.hotel.description : 'Chưa có mô tả.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                ),
                // --- Phần Tiện ích ---
                if (widget.hotel.amenities.isNotEmpty) ...[
                  const Divider(height: 32),
                  Text(
                    "Tiện ích nổi bật",
                     style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12.0, // Tăng khoảng cách chip
                    runSpacing: 8.0,
                    children: widget.hotel.amenities.map((amenity) {
                      return Chip(
                        avatar: Icon(
                          _allAmenities[amenity] ?? Icons.check_circle_outline, // Icon mặc định
                          size: 18,
                          color: Colors.indigo,
                        ),
                        label: Text(amenity, style: const TextStyle(fontSize: 13)),
                        backgroundColor: Colors.indigo.withOpacity(0.08), // Màu nền nhẹ
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // --- THÊM PHẦN CHỌN NGÀY ---
          const Divider(height: 1), // Đường kẻ mỏng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Tăng padding dọc
            child: Row(
              children: [
                Expanded( // Widget chọn ngày nhận phòng
                  child: InkWell( // Dùng InkWell để có hiệu ứng nhấn
                    onTap: () => _selectDate(context, true),
                    child: Padding( // Thêm padding bên trong InkWell
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nhận phòng', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            dateFormat.format(_checkIn),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding( // Icon mũi tên ở giữa
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward, color: Colors.grey[400]),
                ),
                Expanded( // Widget chọn ngày trả phòng
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // Căn phải
                        children: [
                          Text('Trả phòng', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                           const SizedBox(height: 2),
                          Text(
                            dateFormat.format(_checkOut),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ---------------------------

          Container(height: 8, color: Colors.grey[200]), // Dải phân cách

          // --- Phần Danh sách phòng ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Padding trên/dưới
            child: Text(
              "Chọn phòng",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _buildRoomList(context, roomProvider), // Dùng hàm helper mới

          Container(height: 8, color: Colors.grey[200]), // Dải phân cách

          // --- Phần Đánh giá ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row( // Tiêu đề đánh giá và nút xem tất cả (nếu có)
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đánh giá (${reviewProvider.reviews.length})",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (reviewProvider.reviews.length > 3) // Ví dụ: chỉ hiện nút nếu > 3 review
                  TextButton(onPressed: (){ /* TODO: Điều hướng đến trang xem tất cả review */}, child: const Text('Xem tất cả'))
              ],
            ),
          ),
          _buildReviewList(context, reviewProvider), // Dùng hàm helper
          const SizedBox(height: 16), // Khoảng trống cuối trang
        ],
      ),
    );
  }

  // --- CẬP NHẬT HÀM NÀY ĐỂ DÙNG RoomCardWidget ---
  Widget _buildRoomList(BuildContext context, RoomProvider provider) {
    if (provider.isLoading) {
      return const SizedBox( // Giữ chỗ khi loading
         height: 150,
         child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.error != null) {
      return Padding( // Padding cho thông báo lỗi
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: Text('Lỗi tải danh sách phòng: ${provider.error}')),
      );
    }
    if (provider.filteredRooms.isEmpty) {
       return const Padding( // Padding cho thông báo trống
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            'Không có phòng trống cho ngày đã chọn.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column( 
      children: provider.filteredRooms.map((room) {
        final bool isActuallyAvailable = room.available;

        return RoomCardWidget(
          room: room,
          isAvailable: true,
          onBookNowPressed: () {
            Navigator.pushNamed(
              context,
              '/booking',
              arguments: {
                'hotelId': widget.hotel.id,
                'roomId': room.roomId,
                'pricePerNight': room.pricePerNight,
                'checkIn': _checkIn,     // TRUYỀN NGÀY ĐI
                'checkOut': _checkOut, // TRUYỀN NGÀY ĐI
              },
            );
          },
        );
      }).toList(),
    );
  }

  // --- Hàm build danh sách review (Giữ nguyên) ---
  Widget _buildReviewList(BuildContext context, ReviewProvider provider) {
    if (provider.isLoading) {
      // Không cần hiển thị loading ở đây nếu đã có ở trên
      return const SizedBox.shrink();
    }
    if (provider.error != null) {
       return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: Text('Lỗi tải đánh giá: ${provider.error}')),
      );
    }
    if (provider.reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: Text('Chưa có đánh giá nào.', style: TextStyle(color: Colors.grey))),
      );
    }

    // Chỉ hiển thị tối đa 3 review đầu tiên (ví dụ)
    final reviewsToShow = provider.reviews.take(3).toList();

    // Dùng Column thay vì ListView lồng nhau
    return Column(
       children: reviewsToShow.map((review) {
         return Card(
           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           elevation: 1, // Giảm độ nổi
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
           child: Padding(
             padding: const EdgeInsets.all(12.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                     Text(DateFormat('dd/MM/yyyy').format(review.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                   ],
                 ),
                 const SizedBox(height: 4),
                 RatingBarIndicator(
                   rating: review.rating,
                   itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                   itemSize: 16.0, // Sao nhỏ hơn
                 ),
                 const SizedBox(height: 8),
                 Text(review.comment),
               ],
             ),
           ),
         );
       }).toList(),
    );
  }
}