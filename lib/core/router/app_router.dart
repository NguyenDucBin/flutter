// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:doanflutter/features/auth/presentation/pages/auth_gate.dart';
import 'package:doanflutter/features/auth/presentation/pages/sign_in_page.dart';
import 'package:doanflutter/features/auth/presentation/pages/sign_up_page.dart';
import 'package:doanflutter/features/booking/presentation/pages/booking_list_page.dart';
import 'package:doanflutter/features/booking/presentation/pages/booking_screen.dart';
import 'package:doanflutter/features/customers/presentation/pages/customers_list_page.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/presentation/pages/hotel_detail_page.dart';
import 'package:doanflutter/features/hotel/presentation/pages/hotel_list_page.dart';
import 'package:doanflutter/features/hotel/presentation/pages/hotel_management_page.dart';
import 'package:doanflutter/features/reports/presentation/pages/reports_page.dart';
import 'package:doanflutter/features/rooms/presentation/pages/rooms_list_page.dart';
import 'package:doanflutter/features/rooms/presentation/pages/add_edit_room_page.dart'; 
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth Flow
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case '/sign_in':
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case '/sign_up':
        return MaterialPageRoute(builder: (_) => const SignUpPage());

      // Customer Flow  
      case '/home':
        return MaterialPageRoute(builder: (_) => const HotelListPage());
      case '/my_bookings':
        return MaterialPageRoute(builder: (_) => const BookingListPage());
      case '/booking':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              hotelId: args['hotelId'] as String,
              roomId: args['roomId'] as String,
              pricePerNight: double.parse(args['pricePerNight'].toString()),
            ),
          );
        }
        return _errorRoute('Invalid booking arguments');

      // Admin Flow
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      case '/hotels':
        return MaterialPageRoute(builder: (_) => const HotelManagementPage());
      case '/rooms':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => RoomsListPage(hotelId: args),
          );
        }
        return _errorRoute('Thiếu Hotel ID');

        case '/add_edit_room':
        if (args is Map) {
          return MaterialPageRoute(
            builder: (_) => AddEditRoomPage(
              hotelId: args['hotelId'] as String,
              room: args['room'] as RoomEntity?, // Cho phép null
            ),
          );
        }
        return _errorRoute('Thiếu thông tin Hotel/Room');
        
      case '/customers':
        return MaterialPageRoute(builder: (_) => const CustomersListPage());
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportsPage());

      case '/hotel_detail':
        if (args is HotelEntity) {
          return MaterialPageRoute(
            builder: (_) => HotelDetailPage(hotel: args),
          );
        }
        return _errorRoute('Không có thông tin khách sạn');

      default:
        return _errorRoute('Không tìm thấy trang');
    }
  }

  // Helper method để tạo error route
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text(message)),
      ),
    );
  }
}