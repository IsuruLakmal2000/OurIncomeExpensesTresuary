import 'package:flutter/material.dart';
import 'package:realtionshipincomeapp/services/DatabaseService.dart';

class TotalAmountProvider extends ChangeNotifier {
  double _totalAmount = 0.0;
  final DatabaseService _databaseService = DatabaseService();
  String currentUserId = ""; // Store the current user ID

  double get totalAmount => _totalAmount;

  void listenToTotalAmount() {
    _databaseService.getTotalAmountStream().listen((total) {
      _totalAmount = total;
      notifyListeners(); // Notify listeners to rebuild the UI
    });
  }

  void setCurrentUserId(String userId) {
    currentUserId = userId;
    notifyListeners();
  }

  Future<double> getUserIncome(String userId) async {
    try {
      return await _databaseService.getUserTotalIncome(
        userId,
      ); // Fetch user income from DatabaseService
    } catch (e) {
      print("Error fetching user income: $e");
      return 0.0; // Return 0 in case of an error
    }
  }

  Future<String?> getOtherUserId() async {
    try {
      return await _databaseService.getOtherUserId(); // Fetch other user ID
    } catch (e) {
      print("Error fetching other user ID: $e");
      return null; // Return null in case of an error
    }
  }
}
