import 'package:flutter/material.dart';
import 'package:doanflutter/features/home/presentation/pages/hotel_search_page.dart';
import 'package:doanflutter/features/booking/presentation/pages/booking_list_page.dart';

class UserHomePage extends StatefulWidget {
const UserHomePage({super.key});

@override
State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
int _selectedIndex = 0;

static const List<Widget> _widgetOptions = <Widget>[
// Thay bằng hotel_search_page
HotelSearchPage(),
BookingListPage(),
];

void _onItemTapped(int index) {
setState(() {
_selectedIndex = index;
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
bottomNavigationBar: BottomNavigationBar(
items: const <BottomNavigationBarItem>[
BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
BottomNavigationBarItem(icon: Icon(Icons.luggage), label: 'Chuyến đi'),
],
currentIndex: _selectedIndex,
selectedItemColor: Colors.indigo,
onTap: _onItemTapped,
),
);
}
}