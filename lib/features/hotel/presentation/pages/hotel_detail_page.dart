import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';
import 'package:doanflutter/features/booking/presentation/pages/booking_screen.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotel.name),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          if (widget.hotel.imageUrls.isNotEmpty)
            Image.network(
              widget.hotel.imageUrls.first,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 250,
                child: Center(child: Icon(Icons.error)),
              ),
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
}