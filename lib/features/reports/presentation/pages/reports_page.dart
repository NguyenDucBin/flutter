import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // 👈 THÊM IMPORT ĐỂ SỬA LỖI
import 'package:provider/provider.dart';
import 'package:doanflutter/features/auth/presentation/provider/auth_service.dart';
import 'package:doanflutter/features/reports/presentation/provider/report_provider.dart';
import 'package:doanflutter/features/reports/domain/entities/report_entity.dart';
import 'package:doanflutter/features/booking/presentation/pages/admin_booking_list_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageSate();
}

class _ReportsPageSate extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu ngay khi trang được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().user;
      if (user != null) {
        context.read<ReportProvider>().fetchReport(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final currency = NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.hotel_outlined),
            tooltip: 'Manage Hotels',
            onPressed: () => Navigator.pushNamed(context, '/hotels'),
          ),
          IconButton(
            icon: const Icon(Icons.book_online_outlined),
            tooltip: 'Manage Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminBookingListPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: _buildBody(context, provider, currency),
    );
  }

  // Tách body ra cho sạch sẽ
  Widget _buildBody(
    BuildContext context,
    ReportProvider provider,
    NumberFormat currency,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Lỗi: ${provider.error}'));
    }

    if (provider.reportData == null) {
      return const Center(
        child: Text(
          'Không có dữ liệu báo cáo.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final report = provider.reportData!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Tổng quan
          const Text(
            'Overview (Last 6 Months)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Các thẻ thống kê (LẤY TỪ PROVIDER)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                title: 'Total Revenue',
                value: currency.format(report.totalRevenue),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Bookings',
                value: report.totalBookings.toString(),
                icon: Icons.hotel,
                color: Colors.indigo,
              ),
              // (Bạn có thể thêm logic tính Occupancy sau)
            ],
          ),
          const SizedBox(height: 24),

          // Biểu đồ doanh thu (LẤY TỪ PROVIDER)
          const Text(
            'Revenue (Last 6 Months)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  _buildLineChartData(report),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Tạo dữ liệu cho LineChart từ ReportEntity
  LineChartData _buildLineChartData(ReportEntity report) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    
    // Tạo 6 điểm FlSpot (từ 5 tháng trước đến tháng này)
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final month = date.month;
      
      // Lấy doanh thu của tháng, chia cho 1 triệu cho dễ nhìn
      final revenue = (report.monthlyRevenue[month] ?? 0.0) / 1000000.0; 
      
      // index (0-5)
      final chartIndex = (5 - i).toDouble(); 
      spots.add(FlSpot(chartIndex, revenue));
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) =>
                _bottomTitleWidgets(value, meta, now),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          spots: spots,
          color: Colors.indigo,
          barWidth: 4,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.indigo.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  // Helper: Tạo nhãn X-Axis (Tên tháng)
  Widget _bottomTitleWidgets(double value, TitleMeta meta, DateTime endDate) {
    final months = <String>[];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(endDate.year, endDate.month - i, 1);
      months.add(DateFormat('MMM').format(date)); // 'Oct', 'Sep', etc.
    }
    // Lấy tên tháng dựa trên index (0-5)
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(months[value.toInt() % months.length]),
    );
  }

  // (Copy hàm _buildStatCard từ file cũ của bạn vào đây)
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}