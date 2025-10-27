import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/presentation/pages/hotel_detail_page.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  double _minPrice = 0;
  double _maxPrice = 9000000; // Removed digit separator
  final List<String> _selectedFilters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tải danh sách hotels cho user
      context.read<HotelProvider>().fetchAllHotels();
    });
  }

  Widget _buildFilterSidebar() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Price range'),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 9000000, // Removed digit separator
              divisions: 9,
              labels: RangeLabels('${_minPrice.toInt()}', '${_maxPrice.toInt()}'),
              onChanged: (r) {
                setState(() {
                  _minPrice = r.start;
                  _maxPrice = r.end;
                });
              },
            ),
            const SizedBox(height: 8),
            const Text('Room type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Double', 'Single', 'Suite', 'Family']
                  .map((t) => FilterChip(
                        label: Text(t),
                        selected: _selectedFilters.contains(t),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _selectedFilters.add(t);
                            } else {
                              _selectedFilters.remove(t);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCardFromEntity(HotelEntity hotel) {
    final image = (hotel.imageUrls.isNotEmpty) ? hotel.imageUrls.first : null;
    // Giá giả nếu entity chưa có price; nếu có trường price trong entity, dùng nó.
    final priceText = (hotel is HotelEntity) ? 'Giá từ' : 'Giá';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image != null
                  ? Image.network(image, width: 140, height: 95, fit: BoxFit.cover)
                  : Container(
                      width: 140,
                      height: 95,
                      color: Colors.grey[200],
                      child: const Icon(Icons.photo, size: 40, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(hotel.address, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Text(hotel.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Colors.blue, size: 14),
                              SizedBox(width: 4),
                              Text('8.2', style: TextStyle(color: Colors.blue)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('65 reviews', style: TextStyle(color: Colors.grey)),
                      ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Giá từ X VND', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                            onPressed: () {
                              // Sử dụng MaterialPageRoute trực tiếp thay vì pushNamed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HotelDetailPage(hotel: hotel),
                                ),
                              );
                            },
                            child: const Text('Check Availability'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<HotelEntity> hotels) {
    final filtered = hotels.where((h) {
      // Lọc cơ bản: hiện tại chỉ áp giá giả (nếu có trường giá trong entity -> dùng)
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Không tìm thấy khách sạn', style: TextStyle(color: Colors.grey)),
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildHotelCardFromEntity(filtered[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final hotels = provider.allHotels;

    return Scaffold(
      drawer: Drawer(child: _buildFilterSidebar()),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm khách sạn, địa điểm...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                onSubmitted: (q) {
                  // Bạn có thể gọi provider.search(q) nếu cần
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () {},
              icon: const Icon(Icons.calendar_today),
              label: const Text('Dates'),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.filter_list, color: Colors.black54),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Đăng xuất',
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSidebar(),
              const VerticalDivider(width: 1),
              Expanded(child: _buildResultsList(hotels)),
            ],
          );
        } else {
          return _buildResultsList(hotels);
        }
      }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
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

MaterialPageRoute _errorRoute(String message) {
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Lỗi')),
      body: Center(child: Text(message)),
    ),
  );
}