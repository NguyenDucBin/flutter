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
// Thay thế HotelListPage bằng UserHomePage hoặc trang tìm kiếm nếu cần
// import 'package:doanflutter/features/hotel/presentation/pages/hotel_list_page.dart';
import 'package:doanflutter/features/home/presentation/pages/user_home_page.dart'; // Import UserHomePage
import 'package:doanflutter/features/hotel/presentation/pages/hotel_management_page.dart';
import 'package:doanflutter/features/reports/presentation/pages/reports_page.dart';
import 'package:doanflutter/features/rooms/presentation/pages/rooms_list_page.dart';
import 'package:doanflutter/features/rooms/presentation/pages/add_edit_room_page.dart';
import 'package:doanflutter/features/rooms/domain/entities/room_entity.dart';
// Thêm import cho AdminHomePage nếu chưa có
import 'package:doanflutter/features/home/presentation/pages/admin_home_page.dart';


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
      // '/home' bây giờ sẽ trỏ đến UserHomePage (chứa BottomNavBar)
      case '/home':
         return MaterialPageRoute(builder: (_) => const UserHomePage());
      // Trang My Bookings không cần route riêng vì đã có trong UserHomePage
      // case '/my_bookings':
      //   return MaterialPageRoute(builder: (_) => const BookingListPage());

      case '/booking':
        if (args is Map<String, dynamic> &&
            args.containsKey('hotelId') &&
            args.containsKey('roomId') &&
            args.containsKey('pricePerNight') &&
            args.containsKey('checkIn') && // <-- KIỂM TRA THÊM
            args.containsKey('checkOut')) { // <-- KIỂM TRA THÊM
          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              hotelId: args['hotelId'] as String,
              roomId: args['roomId'] as String,
              pricePerNight: (args['pricePerNight'] as num).toDouble(), // Chuyển đổi an toàn
              checkIn: args['checkIn'] as DateTime,     // <-- LẤY NGÀY
              checkOut: args['checkOut'] as DateTime, // <-- LẤY NGÀY
            ),
          );
        }
        return _errorRoute('Thiếu thông tin đặt phòng hoặc sai kiểu dữ liệu');

       case '/hotel_detail':
        if (args is HotelEntity) {
          return MaterialPageRoute(
            builder: (_) => HotelDetailPage(hotel: args),
          );
        }
        return _errorRoute('Không có thông tin khách sạn');


      // Admin Flow
      // '/admin_home' trỏ đến AdminHomePage (chứa BottomNavBar)
      case '/admin_home':
        return MaterialPageRoute(builder: (_) => const AdminHomePage());
      // Các trang con của Admin không cần route riêng nếu truy cập qua BottomNavBar
      // case '/dashboard': // Đã có trong AdminHomePage
      //   return MaterialPageRoute(builder: (_) => const ReportsPage());
      case '/hotels': // Trang quản lý KS (vẫn cần để push từ dashboard)
        return MaterialPageRoute(builder: (_) => const HotelManagementPage());
      case '/rooms': // Trang quản lý phòng (truyền hotelId)
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => RoomsListPage(hotelId: args),
          );
        }
        return _errorRoute('Thiếu Hotel ID để xem phòng');

      case '/add_edit_room': // Trang thêm/sửa phòng
        if (args is Map<String, dynamic> && args.containsKey('hotelId')) {
          return MaterialPageRoute(
            builder: (_) => AddEditRoomPage(
              hotelId: args['hotelId'] as String,
              room: args['room'] as RoomEntity?, // Lấy room (có thể null)
            ),
          );
        }
        return _errorRoute('Thiếu thông tin Hotel/Room để thêm/sửa');

      // case '/customers': // Đã có trong AdminHomePage
      //   return MaterialPageRoute(builder: (_) => const CustomersListPage());
      // case '/reports': // Đã có trong AdminHomePage
      //   return MaterialPageRoute(builder: (_) => const ReportsPage());


      // Route mặc định nếu không khớp
      default:
        // Có thể điều hướng về trang lỗi 404 hoặc trang home tùy ý
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: Center(child: Text('Không tìm thấy trang: ${settings.name}')),
                ));
    }
  }

  // Helper method để tạo error route (Giữ nguyên)
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi Điều Hướng')),
        body: Center(child: Text(message)),
      ),
    );
  }
}