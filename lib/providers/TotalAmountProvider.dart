import 'package:flutter/material.dart';
import 'package:realtionshipincomeapp/services/DatabaseService.dart';

class TotalAmountProvider extends ChangeNotifier {
  double _totalAmount = 0.0;
  final DatabaseService _databaseService = DatabaseService();

  double get totalAmount => _totalAmount;

  void listenToTotalAmount() {
    _databaseService.getTotalAmountStream().listen((total) {
      _totalAmount = total;
      notifyListeners();
    });
  }
}
