import 'package:flutter/material.dart';

class ExpenseTab extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Future<void> Function() fetchTransactions;
  final Future<void> Function(String key) deleteTransaction;

  const ExpenseTab({
    Key? key,
    required this.transactions,
    required this.fetchTransactions,
    required this.deleteTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseTransactions =
        transactions
            .where((t) => t["type"] == "Expense")
            .toList()
            .reversed
            .take(20)
            .toList();

    return ListView.builder(
      itemCount: expenseTransactions.length,
      itemBuilder: (context, index) {
        final expense = expenseTransactions[index];
        return ListTile(
          leading: Icon(Icons.arrow_downward, color: Colors.red),
          title: Text(expense["reason"]),
          subtitle: Row(
            children: [
              Text(
                DateTime.parse(
                  expense["timestamp"],
                ).toLocal().toString().substring(0, 16).replaceFirst('T', ' '),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "- Rs.${expense["amount"]}",
                style: TextStyle(color: Colors.red),
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
                                await deleteTransaction(expense["key"]);
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
  }
}
