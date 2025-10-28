import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class BookingCard extends StatelessWidget {
  final BookingEntity booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final nights = booking.checkOut.difference(booking.checkIn).inDays;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN');
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Lấy tên khách sạn và loại phòng từ Provider
    final hotelName = booking.hotelName;
    final roomType = booking.roomType;

    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero, // Margin đã có ở ListView.separated
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Để bo góc ảnh (nếu có)
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng trên: Tên Khách sạn và Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    hotelName, // Thay đổi chỗ này
                    style: const TextStyle(
                      fontSize: 17, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.indigo
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(booking.status, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: _statusColor(booking.status),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 12),

            // Thông tin phòng và ngày
            Row(
              children: [
                Icon(Icons.king_bed_outlined, color: Colors.grey[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Phòng: $roomType", // Thay đổi chỗ này
                    style: TextStyle(color: Colors.grey[800])
                  )
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.grey[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${dateFormat.format(booking.checkIn)} - ${dateFormat.format(booking.checkOut)} ($nights đêm)",
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 12),

            // Dòng dưới: Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Tổng cộng: ",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  currencyFormat.format(booking.totalPrice),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm helper lấy màu trạng thái (giống trong list page)
  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange.shade600;
      case 'confirmed': return Colors.green.shade600;
      case 'canceled': return Colors.red.shade600;
      default: return Colors.grey.shade600;
    }
  }
}