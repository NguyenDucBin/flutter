import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/booking/presentation/provider/booking_provider.dart';
import 'package:doanflutter/features/booking/presentation/widgets/booking_card_widget.dart';

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
            if (booking.status == 'pending')
              _buildAdminActions(context, booking.bookingId),
          ],
        );
      },
    );
  }

  Widget _buildAdminActions(BuildContext context, String bookingId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          TextButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            label: const Text('Confirm', style: TextStyle(color: Colors.green)),
            onPressed: () {
              context.read<BookingProvider>().updateBookingStatus(bookingId, 'confirmed');
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<BookingProvider>().updateBookingStatus(bookingId, 'canceled');
            },
          ),
        ],
      ),
    );
  }
}