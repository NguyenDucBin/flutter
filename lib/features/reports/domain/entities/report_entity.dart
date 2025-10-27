import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final double totalRevenue;
  final int totalBookings;
  // Dữ liệu cho biểu đồ: Map<Tháng, Doanh thu>
  // Ví dụ: { 10: 15000000, 9: 12000000 } (Tháng 10, Tháng 9)
  final Map<int, double> monthlyRevenue;

  const ReportEntity({
    required this.totalRevenue,
    required this.totalBookings,
    required this.monthlyRevenue,
  });

  @override
  List<Object?> get props => [totalRevenue, totalBookings, monthlyRevenue];
}