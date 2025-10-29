import 'package:flutter/material.dart';
import 'package:doanflutter/features/home/presentation/pages/hotel_search_page.dart';
import 'package:doanflutter/features/booking/presentation/pages/booking_list_page.dart';
import 'package:doanflutter/features/favorites/presentation/pages/favorites_page.dart'; 

class UserHomePage extends StatefulWidget {
const UserHomePage({super.key});

@override
State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
int _selectedIndex = 0; // Bắt đầu từ tab Tìm kiếm (index 0)

static const List<Widget> _widgetOptions = <Widget>[
  HotelSearchPage(), // Index 0
  FavoritesPage(),   // Index 1 (Yêu thích) - Trang này cần được tạo
  BookingListPage(), // Index 2 (Chuyến đi)
];

void _onItemTapped(int index) {
setState(() {
_selectedIndex = index;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
// Sử dụng IndexedStack để giữ trạng thái các trang con khi chuyển tab
body: IndexedStack(
index: _selectedIndex,
children: _widgetOptions,
),

bottomNavigationBar: BottomNavigationBar(
items: const <BottomNavigationBarItem>[
BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'), // Thêm item Yêu thích
BottomNavigationBarItem(icon: Icon(Icons.luggage), label: 'Chuyến đi'), // Item Chuyến đi
],

currentIndex: _selectedIndex,
selectedItemColor: Colors.indigo,
// Có thể thêm unselectedItemColor nếu muốn
// unselectedItemColor: Colors.grey,
type: BottomNavigationBarType.fixed, // Quan trọng khi có > 2 items
onTap: _onItemTapped,
),
);
}
}