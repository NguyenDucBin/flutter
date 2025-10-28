// lib/features/booking/presentation/pages/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';
import 'package:intl/intl.dart'; // <-- ĐÃ THÊM
// --- THÊM IMPORT CHO RoomEntity ---
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
// ---------------------------------


class BookingScreen extends StatefulWidget {
  final String hotelId;
  final String roomId;
  final double pricePerNight;
  // --- THÊM 2 TRƯỜNG MỚI ---
  final DateTime checkIn;
  final DateTime checkOut;

  const BookingScreen({
    super.key,
    required this.hotelId,
    required this.roomId,
    required this.pricePerNight,
    required this.checkIn, // <-- YÊU CẦU
    required this.checkOut, // <-- YÊU CẦU
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // BỎ _checkIn, _checkOut từ initState

  Future<void> _createBooking(BuildContext context) async {
    final user = context.read<AuthService>().user;
    if (user == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập lại.')),
      );
      return; // Nên kiểm tra sớm
    }

    // Lấy thông tin cần thiết từ providers
    // Nên dùng read vì thông tin này không thay đổi trong màn hình này
    final hotel = context.read<HotelProvider>().getHotelById(widget.hotelId);
    // --- SỬA LỖI Ở ĐÂY: Gọi đúng hàm getRoomById ---
    final RoomEntity? room = context.read<RoomProvider>().getRoomById(widget.roomId); // <--- Kiểu trả về là RoomEntity?
    // --- KẾT THÚC SỬA LỖI ---

    // --- SỬA KIỂM TRA NULL ---
    if (hotel == null || room == null) { // Kiểm tra room == null
    // --- KẾT THÚC SỬA ---
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể lấy thông tin phòng hoặc khách sạn.')),
      );
      return;
    }

    final booking = BookingEntity(
      userId: user.uid,
      ownerId: hotel.ownerId, // Lấy ownerId từ hotel entity
      hotelId: widget.hotelId,
      hotelName: hotel.name,   // Lấy tên hotel từ entity
      roomId: widget.roomId,
      // --- TRUY CẬP room.type AN TOÀN ---
      roomType: room.type,    // Truy cập trực tiếp vì đã kiểm tra null ở trên
      // --- KẾT THÚC SỬA ---
      checkIn: widget.checkIn,   // <-- DÙNG BIẾN CỦA WIDGET
      checkOut: widget.checkOut, // <-- DÙNG BIẾN CỦA WIDGET
      totalPrice: _calcTotal(),
      status: 'pending', // Trạng thái ban đầu
    );

    try {
      // Lấy provider (dùng read vì chỉ gọi hàm)
      final provider = context.read<BookingProvider>();
      await provider.createBooking(booking);

      // Kiểm tra `mounted` trước khi dùng context trong hàm async
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt phòng thành công!'), backgroundColor: Colors.green),
        );
        // Điều hướng về màn hình chính của user (ví dụ: '/home') sau khi đặt thành công
        // popUntil('/') sẽ xóa hết các trang trên '/'
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
        // TODO: Chuyển sang tab "Chuyến đi" trên UserHomePage nếu cần
      }
    } catch (e) {
      // Xử lý lỗi (ví dụ: phòng đã được đặt)
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt phòng thất bại: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
    // Không cần finally vì provider tự xử lý isCreatingBooking
  }

  // Hàm tính tổng tiền (chính xác hơn)
  double _calcTotal() {
    // Tính số đêm (luôn dương)
    final nights = widget.checkOut.difference(widget.checkIn).inDays;
    // Đảm bảo ít nhất 1 đêm nếu checkIn và checkOut cùng ngày (ít xảy ra)
    final totalNights = (nights <= 0) ? 1 : nights;
    return widget.pricePerNight * totalNights;
  }

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày và tiền tệ
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);
    // Lắng nghe trạng thái loading từ provider
    final bookingProvider = context.watch<BookingProvider>();

    // Lấy tên KS và loại phòng để hiển thị (an toàn hơn)
    final hotelName = context.read<HotelProvider>().getHotelName(widget.hotelId) ?? 'Khách sạn';
    // --- SỬA CÁCH LẤY roomType ---
    final roomType = context.read<RoomProvider>().getRoomType(widget.roomId) ?? 'Phòng'; // Dùng hàm getRoomType đã sửa
    // --- KẾT THÚC SỬA ---


    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận Đặt phòng'),
        backgroundColor: Colors.indigo, // Màu nhất quán
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Vui lòng kiểm tra lại thông tin:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // --- HIỂN THỊ THÔNG TIN ĐẶT PHÒNG ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Padding chung cho Card
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Căn trái các mục
                  children: [
                    // Thông tin khách sạn/phòng
                    Row(
                      children: [
                        const Icon(Icons.business_outlined, color: Colors.indigo, size: 20),
                        const SizedBox(width: 8),
                        Expanded( // Cho phép tên dài xuống dòng
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hotelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Phòng: $roomType', style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24), // Tăng chiều cao Divider

                    // Ngày nhận phòng
                    _buildBookingInfoRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.green,
                      label: 'Nhận phòng',
                      value: dateFormat.format(widget.checkIn),
                    ),
                    const SizedBox(height: 12), // Khoảng cách giữa các dòng

                    // Ngày trả phòng
                    _buildBookingInfoRow(
                      icon: Icons.calendar_today,
                      iconColor: Colors.redAccent,
                      label: 'Trả phòng',
                      value: dateFormat.format(widget.checkOut),
                    ),
                     const SizedBox(height: 12),

                    // Tổng số đêm
                     _buildBookingInfoRow(
                      icon: Icons.nights_stay_outlined,
                      iconColor: Colors.blueGrey,
                      label: 'Số đêm',
                      value: '${widget.checkOut.difference(widget.checkIn).inDays} đêm',
                    ),
                    const Divider(height: 24),

                    // Tổng tiền
                     _buildBookingInfoRow(
                      icon: Icons.attach_money,
                      iconColor: Colors.orange,
                      label: 'Tổng cộng',
                      value: currencyFormat.format(_calcTotal()),
                      isValueBold: true, // Làm đậm giá tiền
                      valueColor: Colors.indigo, // Màu giá tiền
                      valueSize: 18, // Cỡ chữ giá tiền
                    ),
                  ],
                ),
              ),
            ),
            // ------------------------------------

            const Spacer(), // Đẩy nút xuống dưới cùng

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50), // Nút to hơn
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
              onPressed: bookingProvider.isCreatingBooking
                  ? null // Vô hiệu hóa nút khi đang xử lý
                  : () => _createBooking(context),
              child: bookingProvider.isCreatingBooking
                  ? const SizedBox( // Spinner nhỏ hơn
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                  : const Text('Xác nhận & Đặt phòng', style: TextStyle(fontSize: 16)),
            ),
             const SizedBox(height: 16), // Khoảng trống dưới nút
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isValueBold = false,
    Color? valueColor,
    double? valueSize,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text('$label:', style: TextStyle(color: Colors.grey[700])),
        const Spacer(), // Đẩy giá trị sang phải
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize ?? 16,
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor, // Mặc định là màu text thường
          ),
        ),
      ],
    );
  }
}