import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:doanflutter/features/booking/presentation/widgets/booking_card_widget.dart';
import 'package:doanflutter/features/booking/domain/entities/booking_entity.dart';

class AdminBookingListPage extends StatefulWidget {
  const AdminBookingListPage({super.key});

  @override
  State<AdminBookingListPage> createState() => _AdminBookingListPageState();
}

class _AdminBookingListPageState extends State<AdminBookingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().user;
      if (user != null) {
        context.read<BookingProvider>().fetchBookingsForOwner(user.uid);
      }
    });
  }

  Future<void> _refresh() async {
    final user = context.read<AuthService>().user;
    if (user != null) {
      await context.read<BookingProvider>().fetchBookingsForOwner(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.adminBookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        backgroundColor: Colors.indigo,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(context, bookingProvider, bookings),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookingProvider provider, List<dynamic> bookings) {
    if (provider.isLoadingAdminList) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Column(
          children: [
            BookingCard(booking: booking),           
            _buildAdminActions(context, booking)
          ],
        );
      },
    );
  }

  Widget _buildAdminActions(BuildContext context, BookingEntity booking) {
    final provider = context.read<BookingProvider>();

    // Hàm helper cho gọn
    Widget actionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
      return TextButton.icon(
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        onPressed: onPressed,
      );
    }
    // Dùng switch-case cho rõ ràng
    switch (booking.status) {
      case 'pending':
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              actionButton('Confirm', Icons.check_circle, Colors.green, () {
                provider.updateBookingStatus(booking.bookingId!, 'confirmed');
              }),
              actionButton('Cancel', Icons.cancel, Colors.red, () {
                provider.updateBookingStatus(booking.bookingId!, 'canceled');
              }),
            ],
          ),
        );
      case 'confirmed':
        return Container(
          decoration: BoxDecoration(color: Colors.green[50]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              actionButton('Check-in', Icons.login, Colors.blue, () {
                 provider.updateBookingStatus(booking.bookingId!, 'checked_in');
              }),
            ],
          ),
        );
      case 'checked_in':
         return Container(
          decoration: BoxDecoration(color: Colors.blue[50]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              actionButton('Check-out', Icons.logout, Colors.purple, () {
                 provider.updateBookingStatus(booking.bookingId!, 'checked_out');
              }),
            ],
          ),
        );
      case 'checked_out':
        return Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          padding: const EdgeInsets.all(8.0),
          child: const Center(child: Text('Đã hoàn thành', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic))),
        );
      case 'canceled':
         return Container(
          decoration: BoxDecoration(color: Colors.red[50]),
          padding: const EdgeInsets.all(8.0),
          child: const Center(child: Text('Đã hủy', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic))),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
