import 'package:flutter/material.dart';
import 'package:health_mate/core/database/database_helper.dart';
import 'package:health_mate/features/health_records/models/health_record.dart';

class HealthRecordProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  List<HealthRecord> _records = [];
  List<HealthRecord> _filteredRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<HealthRecord> get records => _filteredRecords.isEmpty ? _records : _filteredRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all records
  Future<void> loadRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _dbHelper.getAllRecords();
      _filteredRecords = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading records: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new record
  Future<bool> addRecord(HealthRecord record) async {
    try {
      await _dbHelper.insertRecord(record);
      await loadRecords();
      return true;
    } catch (e) {
      _errorMessage = 'Error adding record: $e';
      notifyListeners();
      return false;
    }
  }

  // Update existing record
  Future<bool> updateRecord(HealthRecord record) async {
    try {
      await _dbHelper.updateRecord(record);
      await loadRecords();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating record: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete record
  Future<bool> deleteRecord(int id) async {
    try {
      await _dbHelper.deleteRecord(id);
      await loadRecords();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting record: $e';
      notifyListeners();
      return false;
    }
  }

  // Search/Filter by date
  Future<void> filterByDate(String date) async {
    if (date.isEmpty) {
      _filteredRecords = [];
    } else {
      _filteredRecords = _records.where((record) => record.date == date).toList();
    }
    notifyListeners();
  }

  // Clear filter
  void clearFilter() {
    _filteredRecords = [];
    notifyListeners();
  }

  // Get today's summary
  Map<String, int> getTodaySummary() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayRecords = _records.where((record) => record.date == today);
    
    int totalSteps = 0;
    int totalCalories = 0;
    int totalWater = 0;

    for (var record in todayRecords) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalWater += record.water;
    }

    return {
      'steps': totalSteps,
      'calories': totalCalories,
      'water': totalWater,
    };
  }

  // Get weekly summary for charts
  List<Map<String, dynamic>> getWeeklySummary() {
    final List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final dayRecords = _records.where((record) => record.date == dateStr);

      int totalSteps = 0;
      int totalCalories = 0;
      int totalWater = 0;

      for (var record in dayRecords) {
        totalSteps += record.steps;
        totalCalories += record.calories;
        totalWater += record.water;
      }

      weeklyData.add({
        'date': dateStr,
        'day': _getDayName(date.weekday),
        'steps': totalSteps,
        'calories': totalCalories,
        'water': totalWater,
      });
    }

    return weeklyData;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}