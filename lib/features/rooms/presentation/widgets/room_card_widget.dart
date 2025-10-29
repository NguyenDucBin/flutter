import 'package:flutter/material.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:intl/intl.dart';

class RoomCardWidget extends StatelessWidget {
  final RoomEntity room;
  final VoidCallback onBookNowPressed;
  final bool isAvailable; // Thêm biến này để kiểm soát nút "Book Now"

  const RoomCardWidget({
    super.key,
    required this.room,
    required this.onBookNowPressed,
    this.isAvailable = true, // Mặc định là có sẵn
  });

  @override
  Widget build(BuildContext context) {
    // Định dạng tiền tệ Việt Nam
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Để bo góc ảnh
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Phần hình ảnh (Carousel nếu có nhiều ảnh)
          if (room.imageUrls.isNotEmpty)
            SizedBox(
              height: 180, // Chiều cao cố định cho ảnh
              child: room.imageUrls.length == 1
                  ? Image.network( // Chỉ 1 ảnh thì hiển thị luôn
                      room.imageUrls.first,
                      fit: BoxFit.cover,
                      width: double.infinity, // Lấp đầy chiều rộng
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                      ),
                    )
                  : PageView.builder( // Nhiều ảnh thì dùng PageView
                      itemCount: room.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          room.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                          ),
                        );
                      },
                    ),
            )
          else // Ảnh placeholder nếu không có ảnh
            Container(
              height: 180,
              color: Colors.grey[200],
              child: Center(child: Icon(Icons.bed_outlined, size: 60, color: Colors.grey[400])),
            ),

          // 2. Phần thông tin
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.type,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row( // Hiển thị sức chứa bằng icon
                  children: [
                     Icon(Icons.people_alt_outlined, size: 18, color: Colors.grey[700]),
                     const SizedBox(width: 4),
                     Text('Sức chứa: ${room.capacity} người', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 8),

                // 3. Phần tiện ích (nếu có)
                if (room.amenities.isNotEmpty) ...[
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: room.amenities
                        .map((amenity) => Chip(
                              label: Text(amenity, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.indigo.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact, // Chip nhỏ gọn
                              side: BorderSide.none, // Bỏ viền
                            ))
                        .toList(),
                  ),
                   const SizedBox(height: 12), // Khoảng cách nếu có tiện ích
                ],


                // 4. Phần giá và nút
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end, // Căn chỉnh theo đáy
                  children: [
                    Column( // Hiển thị giá rõ ràng hơn
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Text(
                            currencyFormat.format(room.pricePerNight),
                            style: const TextStyle(
                              fontSize: 18, // Giá to hơn
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          const Text('/ đêm', style: TextStyle(color: Colors.grey, fontSize: 12)),
                       ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable ? Colors.indigo : Colors.grey[400], // Màu nút
                        foregroundColor: Colors.white, // Màu chữ
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Bo góc nút
                      ),
                      // Nếu 'isAvailable' là false, nút sẽ bị vô hiệu hóa
                      onPressed: isAvailable ? onBookNowPressed : null,
                      child: Text(isAvailable ? "Đặt Ngay" : "Đã được đặt"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}