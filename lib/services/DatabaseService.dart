import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> addTransaction({
    required String userId, // Add userId parameter
    required String type,
    required String reason,
    required double amount,
  }) async {
    try {
      await _dbRef.child("transactions").push().set({
        "userId": userId, // Store userId
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
            "key": entry.key, // Include the key of the transaction
            "userId": value["userId"], // Include userId
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

  Future<void> deleteTransaction(String transactionKey) async {
    try {
      await _dbRef.child("transactions").child(transactionKey).remove();
    } catch (e) {
      print("Error deleting transaction: $e");
    }
  }

  Stream<double> getTotalAmountStream() {
    return _dbRef.child("transactions").onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      double total = 0.0;
      data.forEach((key, value) {
        final transaction = value as Map<dynamic, dynamic>;
        final amount =
            double.tryParse(transaction["amount"].toString()) ??
            0.0; // Ensure amount is parsed as double
        final type = transaction["type"] as String;
        total += type == "Income" ? amount : -amount;
      });
      return total;
    });
  }

  Future<void> saveUserDetails({
    required String userId,
    required String displayName,
    required String email,
  }) async {
    try {
      await _dbRef.child("users").child(userId).set({
        "displayName": displayName,
        "email": email,
        "createdAt": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error saving user details: $e");
    }
  }

  Future<String> getUserFirstName(String userId) async {
    try {
      final snapshot = await _dbRef.child("users").child(userId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data["displayName"].split(" ").first; // Extract first name
      }
      return "Unknown";
    } catch (e) {
      print("Error fetching user first name: $e");
      return "Unknown";
    }
  }

  Future<double> getUserTotalIncome(String userId) async {
    try {
      final snapshot =
          await _dbRef
              .child("transactions")
              .orderByChild("userId")
              .equalTo(userId)
              .get(); // Query transactions by userId
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        double totalIncome = 0.0;
        data.forEach((key, value) {
          final transaction = value as Map<dynamic, dynamic>;
          if (transaction["type"] == "Income") {
            totalIncome +=
                double.tryParse(transaction["amount"].toString()) ?? 0.0;
          }
        });
        return totalIncome; // Return the calculated total income
      }
      return 0.0; // Return 0 if no transactions exist
    } catch (e) {
      print("Error fetching user total income: $e");
      return 0.0; // Return 0 in case of an error
    }
  }

  Future<String?> getOtherUserId() async {
    try {
      final snapshot = await _dbRef.child("users").get(); // Fetch all users
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        for (var entry in data.entries) {
          final userId = entry.key as String;

          print('other user id' + userId);
          if (FirebaseAuth.instance.currentUser != null &&
              userId != FirebaseAuth.instance.currentUser!.uid) {
            return userId; // Return the first user ID that is not the current user
          } else {
            print('no user id found');
          }
        }
      }
      return null; // Return null if no other user is found
    } catch (e) {
      print("Error fetching other user ID: $e");
      return null; // Return null in case of an error
    }
  }
}
