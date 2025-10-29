import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotelListPage extends StatefulWidget {
  const HotelListPage({super.key});

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách tất cả khách sạn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelProvider>().fetchAllHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final allHotels = provider.allHotels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Khách Sạn'),
        backgroundColor: Colors.indigo,
         foregroundColor: Colors.white,
         actions: [
           IconButton(
             icon: const Icon(Icons.logout),
             tooltip: 'Đăng xuất',
             onPressed: () => context.read<AuthService>().signOut(),
           ),
         ],
      ),
      backgroundColor: const Color(0xFFF4F6F9),
      body: _buildBody(context, provider, allHotels),
    );
  }

   Widget _buildBody(BuildContext context, HotelProvider provider, List<dynamic> hotels) {
     if (provider.isLoading) {
       return const Center(child: CircularProgressIndicator());
     }
     if (provider.error != null) {
       return Center(child: Text('Lỗi: ${provider.error}'));
     }
     if (hotels.isEmpty) {
       return const Center(child: Text('Chưa có khách sạn nào.'));
     }

     // Hiển thị danh sách khách sạn
     return ListView.builder(
       padding: const EdgeInsets.all(16),
       itemCount: hotels.length,
       itemBuilder: (context, index) {
         final hotel = hotels[index];
         return Card(
           margin: const EdgeInsets.only(bottom: 12),
           elevation: 2,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           child: ListTile(
             contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding cho ListTile
             leading: hotel.imageUrls.isNotEmpty
                 ? ClipRRect( // Bo tròn ảnh
                     borderRadius: BorderRadius.circular(8.0),
                     child: Image.network(
                       hotel.imageUrls.first,
                       width: 70, // Ảnh to hơn chút
                       height: 70,
                       fit: BoxFit.cover,
                     ),
                   )
                 : Container( // Thay CircleAvatar bằng Container vuông bo góc
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: Icon(Icons.business_outlined, color: Colors.indigo.shade300, size: 35),
                   ),
             title: Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             subtitle: Padding( // Thêm padding cho subtitle
               padding: const EdgeInsets.only(top: 4.0),
               child: Text(
                 hotel.address,
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
                 style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
             ),
             trailing: const Icon(Icons.chevron_right, color: Colors.grey),
             onTap: () {
               Navigator.pushNamed(
                 context,
                 '/hotel_detail',
                 arguments: hotel,
               );
             },
           ),
         );
       },
     );
   }
}