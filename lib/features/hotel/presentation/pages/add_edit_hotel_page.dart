import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';


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
  
  // Controller mới cho ô nhập URL
  late final TextEditingController _imageUrlController; 
  bool _isLoading = false;

  late List<String> _imageUrls; // Danh sách này giờ sẽ chứa các link bạn dán vào
  late List<String> _amenities; 

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
    
    // Khởi tạo controller mới
    _imageUrlController = TextEditingController(); 

    _imageUrls = widget.hotel?.imageUrls.toList() ?? []; 
    _amenities = widget.hotel?.amenities.toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose(); // Hủy controller mới
    super.dispose();
  }

  // --- HÀM THÊM URL TỪ Ô NHẬP LIỆU ---
  void _addImageUrl() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      setState(() {
        _imageUrls.add(url);
      });
      _imageUrlController.clear(); // Xóa chữ trong ô
      FocusScope.of(context).unfocus(); // Ẩn bàn phím
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập một URL hợp lệ')),
      );
    }
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 link ảnh')),
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
        imageUrls: _imageUrls, // Lưu danh sách link
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

            //  UI CHO HÌNH ẢNH (IMAGES) 
            const SizedBox(height: 24),
            Text('Hình ảnh (Link URL)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            // GridView hiển thị ảnh (giữ nguyên, nó vẫn hoạt động)
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
                          // Thêm errorBuilder để xử lý link hỏng
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _imageUrls.removeAt(index);
                          });
                        },
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
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_link),
                  onPressed: _addImageUrl,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white
                  ),
                ),
              ],
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