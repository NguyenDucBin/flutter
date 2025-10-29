import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doanflutter/features/hotel/presentation/provider/hotel_provider.dart';
import 'package:doanflutter/features/hotel/domain/entities/hotel_entity.dart';
import 'package:doanflutter/features/hotel/presentation/pages/hotel_detail_page.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:intl/intl.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  final List<String> _allAmenities = [
    'Wifi',
    'Hồ bơi',
    'Bãi đỗ xe',
    'Nhà hàng',
    'Gym',
    'Spa'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelProvider>().fetchAllHotels();
    });
  }

  Widget _buildFilterSidebar(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final priceRange = provider.priceRange;
    final selectedAmenities = provider.selectedAmenities;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Price range'),
            RangeSlider(
              values: priceRange,
              min: 0,
              max: 10000000,
              divisions: 10,
              labels: RangeLabels(
                NumberFormat.compactSimpleCurrency(
                        locale: 'vi_VN', decimalDigits: 0)
                    .format(priceRange.start),
                NumberFormat.compactSimpleCurrency(
                        locale: 'vi_VN', decimalDigits: 0)
                    .format(priceRange.end >= 10000000
                        ? 10000000
                        : priceRange.end),
              ),
              onChanged: (values) {
                context.read<HotelProvider>().setPriceRange(values);
              },
            ),
            const SizedBox(height: 8),
            const Text('Tiện ích'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allAmenities
                  .map(
                    (t) => FilterChip(
                      label: Text(t),
                      selected: selectedAmenities.contains(t),
                      onSelected: (sel) {
                        context.read<HotelProvider>().toggleAmenity(t);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Áp dụng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCardFromEntity(HotelEntity hotel) {
    final image = (hotel.imageUrls.isNotEmpty) ? hotel.imageUrls.first : null;
    final currencyFormat =
        NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

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
                  ? Image.network(image,
                      width: 140, height: 95, fit: BoxFit.cover)
                  : Container(
                      width: 140,
                      height: 95,
                      color: Colors.grey[200],
                      child: const Icon(Icons.photo,
                          size: 40, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(hotel.address, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.blue, size: 14),
                              const SizedBox(width: 4),
                              Text(hotel.avgRating.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.blue)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${hotel.reviewCount} reviews',
                            style: const TextStyle(color: Colors.grey)),
                      ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(hotel.minPrice),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text('/ đêm',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 13)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HotelDetailPage(hotel: hotel),
                                ),
                              );
                            },
                            child: const Text('Xem phòng'),
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
    if (hotels.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Không tìm thấy khách sạn phù hợp với bộ lọc.',
            style: TextStyle(color: Colors.grey)),
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: hotels.length,
      itemBuilder: (context, index) =>
          _buildHotelCardFromEntity(hotels[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();
    final hotels = provider.filteredHotels;

    return Scaffold(
      drawer: Drawer(child: _buildFilterSidebar(context)),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            // Ô tìm kiếm
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm khách sạn, địa điểm...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
                onChanged: (q) {
                  context.read<HotelProvider>().setSearchQuery(q);
                },
              ),
            ),
            const SizedBox(width: 12),

            // 🔹 Nút chọn ngày có hiển thị ngày đã chọn
            Builder(
              builder: (ctx) {
                final provider = context.watch<HotelProvider>();
                final dateFormat = DateFormat('dd/MM');
                String labelText;

                if (provider.startDate != null && provider.endDate != null) {
                  labelText =
                      '${dateFormat.format(provider.startDate!)} - ${dateFormat.format(provider.endDate!)}';
                } else {
                  labelText = 'Chọn ngày';
                }

                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final today = DateTime.now();
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: today,
                      lastDate: DateTime(today.year + 2),
                      helpText: 'Chọn ngày nhận và trả phòng',
                      cancelText: 'Hủy',
                      confirmText: 'Xong',
                      locale: const Locale('vi', 'VN'),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.indigo,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (range != null) {
                      context
                          .read<HotelProvider>()
                          .setDateRange(range.start, range.end);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(labelText),
                );
              },
            ),

            const SizedBox(width: 8),

            // Nút mở bộ lọc
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon:
                    const Icon(Icons.filter_list, color: Colors.black54, size: 28),
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
              _buildFilterSidebar(context),
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
    super.dispose();
  }
}
