import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data'; // Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:provider/provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/core/services/storage_service.dart'; 

class AddEditHotelPage extends StatefulWidget {
  final HotelEntity? hotel;
  
  const AddEditHotelPage({super.key, this.hotel});

  @override
  State<AddEditHotelPage> createState() => _AddEditHotelPageState();
}

class _AddEditHotelPageState extends State<AddEditHotelPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  late List<String> _imageUrls; // Lưu cả link cũ và link mới
  late List<String> _amenities; // Lưu các tiện ích được chọn
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Danh sách tiện ích mẫu
  final Map<String, IconData> _allAmenities = {
    'Wifi': Icons.wifi,
    'Hồ bơi': Icons.pool,
    'Bãi đỗ xe': Icons.local_parking,
    'Nhà hàng': Icons.restaurant,
    'Gym': Icons.fitness_center,
    'Spa': Icons.spa,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel?.name);
    _addressController = TextEditingController(text: widget.hotel?.address);
    _descriptionController = TextEditingController(text: widget.hotel?.description);

    // Phải tạo list mới (.toList()) để tránh tham chiếu
    _imageUrls = widget.hotel?.imageUrls.toList() ?? []; 
    _amenities = widget.hotel?.amenities.toList() ?? [];
    // ----------------------------
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- HÀM TẢI ẢNH MỚI ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final storageService = context.read<StorageService>();
      // Đọc bytes và upload (dùng được cả web/mobile)
      final Uint8List bytes = await image.readAsBytes();
      final String name = image.name.isNotEmpty
          ? image.name
          : 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final downloadUrl = await storageService.uploadImageBytes(
        bytes,
        'hotels',
        fileName: name,
      );

      setState(() {
        _imageUrls.add(downloadUrl);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tải lên ít nhất 1 ảnh')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthService>().user;
      if (user == null) throw Exception('User not logged in');

      final hotel = HotelEntity(
        id: widget.hotel?.id ?? '',
        ownerId: user.uid,
        name: _nameController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        imageUrls: _imageUrls,
        amenities: _amenities,
      );

      if (widget.hotel == null) {
        await context.read<HotelProvider>().createHotel(hotel);
      } else {
        await context.read<HotelProvider>().updateHotel(hotel);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
        title: Text(widget.hotel == null ? 'Add Hotel' : 'Edit Hotel'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Hotel Name'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            // ... (các trường Name, Address, Description giữ nguyên) ...
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            
            // --- UI MỚI CHO TIỆN ÍCH (AMENITIES) ---
            const SizedBox(height: 24),
            Text('Tiện ích', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _allAmenities.entries.map((entry) {
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
                  selectedColor: Colors.indigo.withOpacity(0.2),
                  checkmarkColor: Colors.indigo,
                );
              }).toList(),
            ),
            // -----------------------------------------

            // --- UI MỚI CHO HÌNH ẢNH (IMAGES) ---
            const SizedBox(height: 24),
            Text('Hình ảnh', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
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
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _imageUrls.removeAt(index);
                            // TODO: (Nâng cao) Xóa file trên Storage
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: _isUploading 
                   ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                   : const Icon(Icons.add_a_photo),
              label: Text(_isUploading ? 'Đang tải lên...' : 'Thêm ảnh'),
            ),
            // ---------------------------------------

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveHotel,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : Text(widget.hotel == null ? 'Create Hotel' : 'Update Hotel'),
            ),
          ],
        ),
      ),
    );
  }
}