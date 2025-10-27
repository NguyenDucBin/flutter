import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/rooms/presentation/provider/room_provider.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';

class BookingScreen extends StatefulWidget {
  final String hotelId;
  final String roomId;
  final double pricePerNight;

  const BookingScreen({
    super.key,
    required this.hotelId,
    required this.roomId, 
    required this.pricePerNight,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _checkIn;
  late DateTime _checkOut;

  @override
  void initState() {
    super.initState();
    _checkIn = DateTime.now();
    _checkOut = DateTime.now().add(const Duration(days: 1));
  }

  Future<void> _createBooking(BuildContext context) async {
    final user = context.read<AuthService>().user;
    if (user == null) return;

    // Lấy thông tin cần thiết
    final hotel = context.read<HotelProvider>().getHotelById(widget.hotelId);
    final room = context.read<RoomProvider>().getRoomById(widget.roomId);

    if (hotel == null || room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lấy thông tin phòng/khách sạn')),
      );
      return;
    }

    final booking = BookingEntity(
      userId: user.uid,
      ownerId: hotel.ownerId,
      hotelId: widget.hotelId,
      hotelName: hotel.name,
      roomId: widget.roomId,
      roomType: room.type,
      checkIn: _checkIn,
      checkOut: _checkOut,
      totalPrice: _calcTotal(),
      status: 'pending',
    );

    try {
      await context.read<BookingProvider>().createBooking(booking);
      if (mounted) {
        Navigator.pop(context); // Quay lại màn hình trước
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  double _calcTotal() {
    return widget.pricePerNight * (_checkOut.day - _checkIn.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt phòng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date pickers
            ListTile(
              title: const Text('Ngày nhận phòng'),
              subtitle: Text(_checkIn.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _checkIn,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _checkIn = date);
                }
              },
            ),
            ListTile(
              title: const Text('Ngày trả phòng'),
              subtitle: Text(_checkOut.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _checkOut,
                  firstDate: _checkIn.add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _checkOut = date);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _createBooking(context),
              child: const Text('Xác nhận đặt phòng'),
            ),
          ],
        ),
      ),
    );
  }
}