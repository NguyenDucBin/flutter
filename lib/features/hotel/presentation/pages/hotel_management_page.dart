import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/hotel/presentation/pages/add_edit_hotel_page.dart';

class HotelManagementPage extends StatefulWidget {
  const HotelManagementPage({super.key});

  @override
  State<HotelManagementPage> createState() => _HotelManagementPageState();
}

class _HotelManagementPageState extends State<HotelManagementPage> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách khách sạn của chủ sở hữu này
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().user;
      if (user != null) {
        context.read<HotelProvider>().fetchMyHotels(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final myHotels = provider.myHotels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hotels'),
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // (Chuyển sang trang AddEditHotelPage)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditHotelPage(hotel: null),
            ),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context, provider, myHotels),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HotelProvider provider,
    List<dynamic> myHotels,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Lỗi: ${provider.error}'));
    }

    if (myHotels.isEmpty) {
      return const Center(
        child: Text(
          'Bạn chưa có khách sạn nào.\nNhấn + để thêm mới.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myHotels.length,
      itemBuilder: (context, index) {
        final hotel = myHotels[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: const Icon(Icons.business, color: Colors.purple),
            ),
            title: Text(hotel.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(hotel.address),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                provider.deleteHotel(hotel.id);
              },
            ),
            onTap: () {
              // Điều hướng đến trang RoomsListPage với hotel.id
              Navigator.pushNamed(context, '/rooms', arguments: hotel.id);
            },
          ),
        );
      },
    );
  }
}