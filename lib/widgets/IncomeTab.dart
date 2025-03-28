import 'package:flutter/material.dart';
import '../services/DatabaseService.dart'; // Import DatabaseService

class IncomeTab extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Future<void> Function() fetchTransactions;
  final Future<void> Function(String key) deleteTransaction;

  const IncomeTab({
    Key? key,
    required this.transactions,
    required this.fetchTransactions,
    required this.deleteTransaction,
  }) : super(key: key);

  Future<String> _getUserName(String userId) async {
    final dbService = DatabaseService();
    return await dbService.getUserFirstName(userId); // Fetch user's first name
  }

  @override
  Widget build(BuildContext context) {
    final incomeTransactions =
        transactions
            .where((t) => t["type"] == "Income")
            .toList()
            .reversed
            .take(20)
            .toList();

    return ListView.builder(
      itemCount: incomeTransactions.length,
      itemBuilder: (context, index) {
        final income = incomeTransactions[index];
        return FutureBuilder<String>(
          future: _getUserName(income["userId"]), // Fetch first name
          builder: (context, snapshot) {
            final userName = snapshot.data ?? "Unknown";
            return ListTile(
              leading: Icon(Icons.arrow_upward, color: Colors.green),
              title: Text(income["reason"]),
              subtitle: Row(
                children: [
                  Text(
                    DateTime.parse(income["timestamp"])
                        .toLocal()
                        .toString()
                        .substring(0, 16)
                        .replaceFirst('T', ' '),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$userName", // Display user's first name
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "+ Rs.${income["amount"]}",
                    style: TextStyle(color: Colors.green),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text("Delete Transaction"),
                              content: Text(
                                "Are you sure you want to delete this transaction?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await deleteTransaction(income["key"]);
                                    await fetchTransactions();
                                    Navigator.pop(context);
                                  },
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
