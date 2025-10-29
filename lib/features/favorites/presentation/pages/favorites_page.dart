import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/favorites/presentation/provider/favorites_provider.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/presentation/pages/hotel_detail_page.dart'; // Để điều hướng
import 'package:intl/intl.dart'; // Cho định dạng tiền tệ

class FavoritesPage extends StatefulWidget { // Chuyển thành StatefulWidget
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  // Tải lại favorites khi trang này được hiển thị
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = context.read<AuthService>().user;
        if (user != null) {
          // Gọi fetchFavorites để đảm bảo danh sách là mới nhất
          context.read<FavoritesProvider>().fetchFavorites(user.uid);
          // Cũng nên fetch hotels nếu chưa có
          if (context.read<HotelProvider>().allHotels.isEmpty) {
             context.read<HotelProvider>().fetchAllHotels();
          }
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng watch ở đây để UI cập nhật khi có thay đổi
    final authService = context.watch<AuthService>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    // Dùng watch luôn cho hotelProvider để lấy danh sách hotel mới nhất
    final hotelProvider = context.watch<HotelProvider>();

    final user = authService.user;
    if (user == null) {
      return Scaffold( // Thêm Scaffold để có AppBar
         appBar: AppBar(
          title: const Text('Yêu thích'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Vui lòng đăng nhập để xem yêu thích.')),
      );
    }

    // Lấy danh sách ID yêu thích
    final favoriteIds = favoritesProvider.favoriteHotelIds;

    // Lấy danh sách HotelEntity tương ứng từ HotelProvider
    // Lọc _allHotels thay vì gọi lại API
    final favoriteHotels = hotelProvider.allHotels
        .where((hotel) => favoriteIds.contains(hotel.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khách sạn Yêu thích'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
         actions: [ // Thêm nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () {
               context.read<FavoritesProvider>().fetchFavorites(user.uid);
               context.read<HotelProvider>().fetchAllHotels();
            },
          ),
        ],
      ),
      body: _buildBody(context, favoritesProvider, hotelProvider, favoriteHotels, user.uid),
    );
  }

  Widget _buildBody(BuildContext context, FavoritesProvider favProvider, HotelProvider hotelProvider, List<HotelEntity> hotels, String userId) {
    // Kết hợp cả isLoading của favorites và hotels
    if (favProvider.isLoading || hotelProvider.isLoading && hotels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

     // Hiển thị lỗi từ HotelProvider nếu có
    if (hotelProvider.error != null && hotels.isEmpty) {
       return Center(child: Text("Lỗi tải khách sạn: ${hotelProvider.error}"));
    }

    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có khách sạn yêu thích nào',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn ♡ trên trang chi tiết để thêm.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Hiển thị danh sách khách sạn yêu thích
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        // Truyền userId vào card
        return _buildFavoriteHotelCard(context, hotels[index], userId);
      },
    );
  }

  // Widget riêng để hiển thị card khách sạn yêu thích
  // Thêm userId làm tham số
  Widget _buildFavoriteHotelCard(BuildContext context, HotelEntity hotel, String userId) {
     final image = (hotel.imageUrls.isNotEmpty) ? hotel.imageUrls.first : null;
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: InkWell(
         onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HotelDetailPage(hotel: hotel),
              ),
            );
          },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image != null
                    ? Image.network(image, width: 100, height: 70, fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container( // Xử lý lỗi ảnh
                          width: 100, height: 70, color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 30, color: Colors.grey)
                        ),
                      )
                    : Container(
                        width: 100, height: 70, color: Colors.grey[200],
                        child: const Icon(Icons.photo, size: 30, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hotel.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(hotel.address, style: TextStyle(color: Colors.grey[700], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Row(children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(hotel.avgRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(' (${hotel.reviewCount})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ]),
                        Text(
                          currencyFormat.format(hotel.minPrice),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Nút bỏ yêu thích
              IconButton(
                // Đọc trạng thái yêu thích từ Provider
                icon: Icon(
                    context.watch<FavoritesProvider>().isFavorite(hotel.id)
                        ? Icons.favorite
                        : Icons.favorite_border, // Hiển thị đúng icon
                    color: Colors.redAccent[100]),
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                tooltip: 'Bỏ yêu thích',
                // Gọi toggleFavorite từ Provider
                onPressed: () {
                    context.read<FavoritesProvider>().toggleFavorite(userId, hotel.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}