// lib/features/rooms/presentation/pages/add_edit_room_page.dart
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
  }

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return; // Kiểm tra form

    setState(() => _isLoading = true);

    try {
      final roomData = RoomEntity(
        // Nếu là Cập nhật, giữ nguyên roomId.
        // Nếu là Thêm mới, để trống roomId, Firestore sẽ tự tạo ID.
        // Tuy nhiên, RoomModel của bạn yêu cầu roomId, nên ta sẽ xử lý
        // trong Repository (hiện tại logic của bạn đang tự add, ta cần sửa nhẹ)
        // Tạm thời, chúng ta vẫn cần 1 ID, hãy để Repository xử lý.
        // NHƯNG Entity của bạn yêu cầu roomId.
        // Hãy sửa lại Entity: roomId có thể là String?
        // ---
        // GIẢI PHÁP TỐT NHẤT: Vẫn giữ nguyên Entity.
        // Khi tạo mới, ta sẽ gán một ID tạm ở đây,
        // nhưng hàm createRoom của bạn trong Impl
        // đang dùng .add() (tự tạo ID) thay vì .doc(id).set().
        // Hãy sửa `RoomRepositoryImpl`:
        // Sửa: await _db.collection('hotels').doc(room.hotelId).collection('rooms').add(model.toMap());
        // Thành:
        // DocumentReference docRef;
        // if (room.roomId.isEmpty) {
        //   docRef = _db.collection('hotels').doc(room.hotelId).collection('rooms').doc();
        // } else {
        //   docRef = _db.collection('hotels').doc(room.hotelId).collection('rooms').doc(room.roomId);
        // }
        // await docRef.set(model.toMap());
        //
        // --> Sau khi xem lại code, hàm `createRoom` của bạn
        // dùng `.add()` tức là nó phớt lờ `roomId` từ entity.
        // Và hàm `updateRoom`
        // lại dùng `doc(room.roomId).update()`.
        // -> Logic này HOÀN TOÀN CHÍNH XÁC cho kiến trúc của bạn.
        // Chúng ta chỉ cần truyền đúng entity.

        roomId: widget.room?.roomId ?? '', // Cập nhật: dùng ID cũ. Thêm mới: rỗng.
        hotelId: widget.hotelId,
        type: _typeController.text.trim(),
        pricePerNight: double.tryParse(_priceController.text) ?? 0.0,
        capacity: int.tryParse(_capacityController.text) ?? 2,
        available: _isAvailable,
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
        backgroundColor: Colors.indigo,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Loại phòng (VD: Phòng Đôi, Suite)'),
              validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập loại phòng' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá mỗi đêm (VNĐ)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập giá';
                if (double.tryParse(v) == null) return 'Giá không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: 'Số người tối đa'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập số người';
                if (int.tryParse(v) == null) return 'Số người không hợp lệ';
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
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveRoom,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isEditing ? 'Cập nhật' : 'Thêm mới'),
            ),
          ],
        ),
      ),
    );
  }
}