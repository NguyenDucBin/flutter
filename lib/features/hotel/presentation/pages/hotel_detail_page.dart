import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';
import 'package:doanflutter/features/booking/presentation/pages/booking_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 
import 'package:intl/intl.dart';
import 'package:doanflutter/features/reviews/presentation/provider/review_provider.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelEntity hotel;
  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().fetchRooms(widget.hotel.id);
      context.read<ReviewProvider>().fetchReviews(widget.hotel.id);
    });
  }

  final Map<String, IconData> _allAmenities = {
    'Wifi': Icons.wifi,
    'Hồ bơi': Icons.pool,
    'Bãi đỗ xe': Icons.local_parking,
    'Nhà hàng': Icons.restaurant,
    'Gym': Icons.fitness_center,
    'Spa': Icons.spa,
  };

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.name),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          if (widget.hotel.imageUrls.isNotEmpty)
            SizedBox(
              height: 250,
              // Dùng PageView để lướt qua các ảnh
              child: PageView.builder(
                itemCount: widget.hotel.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.hotel.imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 250,
                      child: Center(child: Icon(Icons.error)),
                    ),
                  );
                },
              ),
            )
          else 
            Container( // Ảnh placeholder nếu không có ảnh
              height: 250,
              color: Colors.grey[200],
              child: Icon(Icons.hotel, size: 100, color: Colors.grey[400]),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.hotel.address,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.hotel.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (widget.hotel.amenities.isNotEmpty) ...[
                  const Divider(height: 32),
                  Text(
                    "Tiện ích",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 12.0,
                    children: widget.hotel.amenities.map((amenity) {
                      return Chip(
                        avatar: Icon(
                          _allAmenities[amenity] ?? Icons.check_box_outline_blank,
                          size: 20,
                          color: Colors.indigo,
                        ),
                        label: Text(amenity),
                        backgroundColor: Colors.indigo.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Available Rooms",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          _buildRoomList(context, roomProvider),

          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Đánh giá (${reviewProvider.reviews.length})",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          _buildReviewList(context, reviewProvider),
        ],
      ),
    );
  }

  Widget _buildRoomList(BuildContext context, RoomProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }
    if (provider.filteredRooms.isEmpty) {
      return const Center(child: Text('No rooms available.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.filteredRooms.length,
      itemBuilder: (context, index) {
        final room = provider.filteredRooms[index];
        if (!room.available) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(room.type),
            subtitle: Text("Price: ${room.pricePerNight} VND/night"),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
              child: const Text("Book Now"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(
                      hotelId: widget.hotel.id,
                      roomId: room.roomId,
                      pricePerNight: room.pricePerNight,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildReviewList(BuildContext context, ReviewProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text('Lỗi tải đánh giá: ${provider.error}'));
    }
    if (provider.reviews.isEmpty) {
      return const Center(child: Text('Chưa có đánh giá nào.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.reviews.length,
      itemBuilder: (context, index) {
        final review = provider.reviews[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('dd/MM/yyyy').format(review.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                RatingBarIndicator(
                  rating: review.rating,
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  itemSize: 18.0,
                ),
                const SizedBox(height: 8),
                Text(review.comment),
              ],
            ),
          ),
        );
      },
    );
  }
}