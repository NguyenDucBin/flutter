import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';
import 'package:intl/intl.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';


class BookingScreen extends StatefulWidget {
  final String hotelId;
  final String roomId;
  final double pricePerNight;
  final DateTime checkIn;
  final DateTime checkOut;

  const BookingScreen({
    super.key,
    required this.hotelId,
    required this.roomId,
    required this.pricePerNight,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Future<void> _createBooking(BuildContext context) async {
    final user = context.read<AuthService>().user;
    if (user == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập lại.')),
      );
      return;
    }

    final hotel = context.read<HotelProvider>().getHotelById(widget.hotelId);
    final RoomEntity? room = context.read<RoomProvider>().getRoomById(widget.roomId);

    if (hotel == null || room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể lấy thông tin phòng hoặc khách sạn.')),
      );
      return;
    }

    final booking = BookingEntity(
      userId: user.uid,
      ownerId: hotel.ownerId,
      hotelId: widget.hotelId,
      hotelName: hotel.name,
      roomId: widget.roomId,
      roomType: room.type,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      totalPrice: _calcTotal(),
      status: 'pending',
    );

    String? successMessage; // Biến lưu thông báo thành công
    String? errorMessage; // Biến lưu thông báo lỗi

    try {
      final provider = context.read<BookingProvider>();
      await provider.createBooking(booking);
      successMessage = 'Đặt phòng thành công!'; // Ghi nhận thành công
    } catch (e) {
      errorMessage = 'Đặt phòng thất bại: ${e.toString()}'; // Ghi nhận lỗi
    }

    // Xử lý hiển thị SnackBar và điều hướng SAU KHI await kết thúc 
    if (!mounted) return; // Kiểm tra mounted một lần nữa sau await

    if (successMessage != null) {
      // Hiển thị SnackBar thành công TRƯỚC khi điều hướng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
      // Điều hướng về trang chủ ('/') và xóa hết stack cũ
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      // TODO (Nâng cao): Thêm cơ chế để UserHomePage tự động chuyển sang tab "Chuyến đi"
      // Ví dụ: Dùng GlobalKey hoặc Provider/Stream để gửi tín hiệu
    } else if (errorMessage != null) {
      // Hiển thị SnackBar lỗi (Không điều hướng khi lỗi)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  // Hàm tính tổng tiền (chính xác hơn)
  double _calcTotal() {
    final nights = widget.checkOut.difference(widget.checkIn).inDays;
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
    final roomType = context.read<RoomProvider>().getRoomType(widget.roomId) ?? 'Phòng';


    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận Đặt phòng'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Vui lòng kiểm tra lại thông tin:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Card thông tin đặt phòng (giữ nguyên)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin khách sạn/phòng
                    Row(
                      children: [
                        const Icon(Icons.business_outlined, color: Colors.indigo, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
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
                    const Divider(height: 24),

                    // Ngày nhận phòng
                    _buildBookingInfoRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.green,
                      label: 'Nhận phòng',
                      value: dateFormat.format(widget.checkIn),
                    ),
                    const SizedBox(height: 12),

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
                      isValueBold: true,
                      valueColor: Colors.indigo,
                      valueSize: 18,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Nút xác nhận (giữ nguyên)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
              onPressed: bookingProvider.isCreatingBooking
                  ? null
                  : () => _createBooking(context),
              child: bookingProvider.isCreatingBooking
                  ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                  : const Text('Xác nhận & Đặt phòng', style: TextStyle(fontSize: 16)),
            ),
             const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Hàm _buildBookingInfoRow (giữ nguyên)
  Widget _buildBookingInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isValueBold = false,
    Color? valueColor,
    double? valueSize,
  }) {
    // ... (Giữ nguyên code của hàm này)
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