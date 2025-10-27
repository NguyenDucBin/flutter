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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel?.name);
    _addressController = TextEditingController(text: widget.hotel?.address);
    _descriptionController = TextEditingController(text: widget.hotel?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;

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
        imageUrls: widget.hotel?.imageUrls ?? [],
        amenities: widget.hotel?.amenities ?? [],
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