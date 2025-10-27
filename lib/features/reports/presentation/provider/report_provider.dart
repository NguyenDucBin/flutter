import 'package:flutter/foundation.dart';
import 'package:doanflutter/features/reports/domain/entities/report_entity.dart';
import 'package:doanflutter/features/reports/domain/repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _reportRepository;
  ReportProvider(this._reportRepository);

  ReportEntity? _reportData;
  ReportEntity? get reportData => _reportData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Action: Tải dữ liệu báo cáo (6 tháng gần nhất)
  Future<void> fetchReport(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      // Đặt mốc thời gian là 6 tháng trước
      final startDate = DateTime(now.year, now.month - 6, now.day);
      
      _reportData = await _reportRepository.getOwnerReport(
        ownerId: ownerId,
        startDate: startDate,
        endDate: now,
      );
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}