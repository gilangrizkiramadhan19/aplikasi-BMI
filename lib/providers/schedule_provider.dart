import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/api_service.dart';
import 'dart:typed_data';

class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;
  int _currentMonth = DateTime.now().month;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentMonth => _currentMonth;

  Future<void> fetchSchedulesByMonth(int month) async {
    _isLoading = true;
    _error = null;
    _currentMonth = month;
    notifyListeners();

    try {
      _schedules = await ApiService.getSchedulesByMonth(month);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> takeTask(int scheduleId) async {
    try {
      await ApiService.takeScheduleTask(scheduleId);
      // Refresh schedules setelah take task
      await fetchSchedulesByMonth(_currentMonth);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitReport(
    int scheduleId,
    String filePath1,
    String filePath2,
    String keterangan,
    String? materialUsed,
    {Uint8List? fileBytes1, Uint8List? fileBytes2}
  ) async {
    try {
      await ApiService.submitScheduleReport(
        scheduleId,
        filePath1,
        filePath2,
        keterangan,
        materialUsed,
        fileBytes1: fileBytes1,
        fileBytes2: fileBytes2,
      );
      // Refresh schedules setelah submit
      await fetchSchedulesByMonth(_currentMonth);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Utility function untuk mendapatkan status badge info
  Map<String, dynamic> getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return {
          'label': 'Menunggu',
          'color': const Color(0xFFFF9800),
          'bgColor': const Color(0xFFFF9800).withOpacity(0.1),
          'canTake': true,
        };
      case 'IN_PROGRESS':
        return {
          'label': 'Sedang Dikerjakan',
          'color': const Color(0xFF2196F3),
          'bgColor': const Color(0xFF2196F3).withOpacity(0.1),
          'canTake': false,
        };
      case 'RESOLVED':
        return {
          'label': 'Selesai',
          'color': const Color(0xFF43A047),
          'bgColor': const Color(0xFF43A047).withOpacity(0.1),
          'canTake': false,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'bgColor': Colors.grey.withOpacity(0.1),
          'canTake': false,
        };
    }
  }
}
