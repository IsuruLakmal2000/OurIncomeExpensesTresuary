import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> addTransaction({
    required String type,
    required String reason,
    required double amount,
  }) async {
    try {
      await _dbRef.child("transactions").push().set({
        "type": type,
        "reason": reason,
        "amount": amount,
        "timestamp": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final snapshot = await _dbRef.child("transactions").get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return {
            "type": value["type"],
            "reason": value["reason"],
            "amount": value["amount"],
            "timestamp": value["timestamp"],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }

  Stream<double> getTotalAmountStream() {
    return _dbRef.child("transactions").onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      double total = 0.0;
      data.forEach((key, value) {
        final transaction = value as Map<dynamic, dynamic>;
        final amount = transaction["amount"] as double;
        final type = transaction["type"] as String;
        total += type == "Income" ? amount : -amount;
      });
      return total;
    });
  }
}
