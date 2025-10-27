import 'package:flutter/material.dart';
import 'package:doanflutter/features/reports/presentation/pages/reports_page.dart';
import 'package:doanflutter/features/hotel/presentation/pages/hotel_management_page.dart';
import 'package:doanflutter/features/booking/presentation/pages/admin_booking_list_page.dart';
import 'package:doanflutter/features/customers/presentation/pages/customers_list_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // Mặc định là Dashboard (Reports)

  // Danh sách các trang quản lý
  static const List<Widget> _widgetOptions = <Widget>[
    ReportsPage(),           // Tab 0: Dashboard/Báo cáo
    HotelManagementPage(),   // Tab 1: Quản lý Khách sạn
    AdminBookingListPage(),  // Tab 2: Quản lý Đặt phòng
    CustomersListPage(),     // Tab 3: Quản lý Khách hàng
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Quan trọng khi có > 3 items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            label: 'Khách sạn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_outlined),
            label: 'Đặt phòng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Khách hàng',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        // Có thể thêm unselectedItemColor nếu muốn
        onTap: _onItemTapped,
      ),
    );
  }
}