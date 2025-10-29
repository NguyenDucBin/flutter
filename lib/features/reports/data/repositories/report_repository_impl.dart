import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanflutter/features/booking/data/models/booking_model.dart'; // Import BookingModel
import 'package:doanflutter/features/reports/domain/entities/report_entity.dart';
import 'package:doanflutter/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final FirebaseFirestore _db;
  ReportRepositoryImpl(this._db);

  @override
  Future<ReportEntity> getOwnerReport({
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // lấy danh sách trong khoảng thời gian đã cho.
    final snapshot = await _db
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'confirmed')
        .where('checkIn', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('checkIn', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    // 2. Khởi tạo các biến để tính toán
    double totalRevenue = 0;
    int totalBookings = 0;
    Map<int, double> monthlyRevenue = {};

    // 3. Lặp qua từng booking để tổng hợp dữ liệu
    for (var doc in snapshot.docs) {
      final booking = BookingModel.fromSnapshot(doc);

      // Tính tổng
      totalRevenue += booking.totalPrice;
      totalBookings++;

      // Tính doanh thu theo tháng
      final month = booking.checkIn.month;
      monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + booking.totalPrice;
    }

    // 4. Trả về đối tượng ReportEntity
    return ReportEntity(
      totalRevenue: totalRevenue,
      totalBookings: totalBookings,
      monthlyRevenue: monthlyRevenue,
    );
  }
}