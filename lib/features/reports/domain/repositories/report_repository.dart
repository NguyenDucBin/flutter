import 'package:doanflutter/features/reports/domain/entities/report_entity.dart';

abstract class ReportRepository {
  // Hợp đồng: Lấy báo cáo cho một chủ khách sạn (admin)
  // trong một khoảng thời gian (ví dụ: 6 tháng qua)
  Future<ReportEntity> getOwnerReport({
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
  });
}