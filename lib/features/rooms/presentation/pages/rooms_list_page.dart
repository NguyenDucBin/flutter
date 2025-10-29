import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';
// --- THÊM IMPORT CHO RoomEntity VÀ NumberFormat ---
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:intl/intl.dart';
// -------------------------------------------


class RoomsListPage extends StatefulWidget {
  final String hotelId;
  const RoomsListPage({super.key, required this.hotelId});

  @override
  State<RoomsListPage> createState() => _RoomsListPageState();
}

class _RoomsListPageState extends State<RoomsListPage> {
  @override
  void initState() {
    super.initState();
    // Ngay khi trang được mở, gọi Provider để tải dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchAllRooms(widget.hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ RoomProvider
    final roomProvider = context.watch<RoomProvider>();
    final filteredRooms = roomProvider.allFilteredRoomsForAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Room Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white, // Thêm màu chữ cho AppBar
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white, // Thêm màu chữ cho FAB
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add_edit_room',
            arguments: {
              'hotelId': widget.hotelId,
              'room': null, // Thêm mới nên room là null
            },
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ô tìm kiếm
            TextField(
              decoration: InputDecoration(
                hintText: 'Search room by type...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Điều chỉnh padding
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              // Gọi provider để cập nhật query
              onChanged: (value) => context.read<RoomProvider>().setSearchQuery(value),
            ),
            const SizedBox(height: 16),

            // Hiển thị trạng thái tải
            if (roomProvider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // Hiển thị lỗi nếu có
            else if (roomProvider.error != null)
              Expanded(child: Center(child: Text("Lỗi: ${roomProvider.error}")))
            // Hiển thị danh sách phòng
            else
              Expanded(
                child: filteredRooms.isEmpty
                    ? const Center(
                        child: Text(
                          'No rooms found',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = filteredRooms[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    room.available ? Colors.green : Colors.redAccent,
                                child: Icon(
                                  room.available ? Icons.check : Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                room.type, // Hiển thị loại phòng
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Price: ${NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0).format(room.pricePerNight)}', // Định dạng tiền tệ
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.pushNamed(
                                      context,
                                      '/add_edit_room',
                                      arguments: {
                                        'hotelId': widget.hotelId,
                                        'room': room,
                                      },
                                    );
                                  } else if (value == 'delete') {
                                    // Gọi provider để xóa
                                    context.read<RoomProvider>().deleteRoom(
                                          widget.hotelId, // Sử dụng widget.hotelId
                                          room.roomId,
                                        );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.indigo),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}