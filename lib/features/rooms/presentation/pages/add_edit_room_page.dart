import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';

class AddEditRoomPage extends StatefulWidget {
  final String hotelId;
  final RoomEntity? room; // Nếu room là null -> Thêm mới. Ngược lại -> Cập nhật

  const AddEditRoomPage({
    super.key,
    required this.hotelId,
    this.room,
  });

  @override
  State<AddEditRoomPage> createState() => _AddEditRoomPageState();
}

class _AddEditRoomPageState extends State<AddEditRoomPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _typeController;
  late final TextEditingController _priceController;
  late final TextEditingController _capacityController;
  late bool _isAvailable;
  bool _isLoading = false;

  late final TextEditingController _imageUrlController; // Cho link ảnh
  late List<String> _imageUrls; // Danh sách link ảnh
  late List<String> _amenities; // Danh sách tiện ích

  // Danh sách tiện ích mẫu cho PHÒNG
  final Map<String, IconData> _allRoomAmenities = {
    'TV': Icons.tv,
    'Ban công': Icons.balcony,
    'Bồn tắm': Icons.bathtub_outlined,
    'View biển': Icons.beach_access,
    'Điều hòa': Icons.ac_unit,
  };

  bool get _isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.room?.type ?? '');
    _priceController = TextEditingController(
        text: widget.room?.pricePerNight.toStringAsFixed(0) ?? '');
    _capacityController =
        TextEditingController(text: widget.room?.capacity.toString() ?? '2');
    _isAvailable = widget.room?.available ?? true;
    _imageUrlController = TextEditingController();
    _imageUrls = widget.room?.imageUrls.toList() ?? [];
    _amenities = widget.room?.amenities.toList() ?? [];
  }

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose(); // Hủy controller mới
    super.dispose();
  }

  // HÀM THÊM LINK ẢNH (SAO CHÉP TỪ ADDEDITHOTELPAGE) 
  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      setState(() {
        _imageUrls.add(url);
      });
      _imageUrlController.clear();
      FocusScope.of(context).unfocus();
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập một URL hợp lệ (bắt đầu bằng http:// hoặc https://)')),
      );
    }
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return; // Kiểm tra form
    // Kiểm tra ảnh
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 link ảnh cho phòng')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final roomData = RoomEntity(
        roomId: widget.room?.roomId ?? '', // ID cũ nếu sửa, rỗng nếu tạo mới
        hotelId: widget.hotelId,
        type: _typeController.text.trim(),
        pricePerNight: double.tryParse(_priceController.text) ?? 0.0,
        capacity: int.tryParse(_capacityController.text) ?? 2,
        available: _isAvailable,
        imageUrls: _imageUrls, 
        amenities: _amenities, 
      );

      final provider = context.read<RoomProvider>();
      if (_isEditing) {
        await provider.updateRoom(roomData);
      } else {
        await provider.createRoom(roomData);
      }

      if (mounted) Navigator.pop(context); // Quay lại trang danh sách
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Cập nhật Phòng' : 'Thêm Phòng Mới'),
        backgroundColor: Colors.indigo, // Màu nhất quán
        foregroundColor: Colors.white, // Màu chữ trên AppBar
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Loại phòng',
                hintText: 'VD: Phòng Đôi, Suite...',
                border: OutlineInputBorder(), // Thêm viền
              ),
              validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập loại phòng' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Giá mỗi đêm',
                suffixText: 'VNĐ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập giá';
                if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Giá không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Số người tối đa',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập số người';
                if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Số người không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Phòng có sẵn (Available)'),
              value: _isAvailable,
              onChanged: (val) {
                setState(() => _isAvailable = val);
              },
              activeColor: Colors.indigo,
              contentPadding: EdgeInsets.zero, // Bỏ padding mặc định
            ),

            const Divider(height: 32, thickness: 1), 
            Text('Tiện ích phòng', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _allRoomAmenities.entries.map((entry) {
                final isSelected = _amenities.contains(entry.key);
                return FilterChip(
                  label: Text(entry.key),
                  avatar: Icon(entry.value, size: 18),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _amenities.add(entry.key);
                      } else {
                        _amenities.remove(entry.key);
                      }
                    });
                  },
                   selectedColor: Colors.indigo.withOpacity(0.15), // Màu đậm hơn
                  checkmarkColor: Colors.indigo,
                  shape: RoundedRectangleBorder( // Bo tròn hơn
                      borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),

            // THÊM UI ẢNH PHÒNG 
            const Divider(height: 32, thickness: 1),
            Text('Hình ảnh phòng (Link URL)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // GridView hiển thị ảnh
            if (_imageUrls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                        ),
                      ),
                       // Nút xóa ảnh
                      Material( // Thêm Material để có hiệu ứng ripple
                        color: Colors.black45, // Nền đen mờ
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _imageUrls.removeAt(index)),
                          tooltip: 'Xóa ảnh',
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 8),
            // Ô nhập link và nút Thêm
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Dán link ảnh (http://...)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding nhỏ hơn
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled( // Dùng filled cho nổi bật
                  icon: const Icon(Icons.add_link),
                  onPressed: _addImageUrl,
                  style: IconButton.styleFrom(backgroundColor: Colors.indigo),
                  tooltip: 'Thêm Link Ảnh',
                ),
              ],
            ),

            const SizedBox(height: 32), // Tăng khoảng cách
            ElevatedButton(
              onPressed: _isLoading ? null : _saveRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white, // Màu chữ
                minimumSize: const Size(double.infinity, 50), // Nút to hơn
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bo tròn
              ),
              child: _isLoading
                  ? const SizedBox( // Spinner nhỏ hơn
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : Text(_isEditing ? 'Cập nhật Phòng' : 'Thêm Phòng Mới', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}