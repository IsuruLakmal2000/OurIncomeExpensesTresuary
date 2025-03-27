import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:realtionshipincomeapp/services/AuthService.dart';
import 'package:realtionshipincomeapp/services/DatabaseService.dart';
import 'package:provider/provider.dart';
import 'package:realtionshipincomeapp/providers/TotalAmountProvider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final transactions = await _databaseService.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  void _openBottomModalSheet() async {
    String? selectedType;
    String reason = "";
    String amount = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add Income/Expense",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items:
                        ["Income", "Expense"]
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Select Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (selectedType != null) ...[
                    SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        reason = value;
                      },
                      decoration: InputDecoration(
                        labelText: "Reason",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        amount = value;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedType != null &&
                          reason.isNotEmpty &&
                          amount.isNotEmpty) {
                        await _databaseService.addTransaction(
                          type: selectedType!,
                          reason: reason,
                          amount: double.parse(amount),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$selectedType added successfully!"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all fields")),
                        );
                      }
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Increase AppBar height
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(''), // Replace with your image path
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${FirebaseAuth.instance.currentUser?.displayName ?? 'My Name'}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Oshini Hansamala",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ), // Replace with the desired name
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              print('ss');
              final user = await _authService.signInWithGoogle();
              if (user != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logged in as ${user.displayName}")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Google Sign-In canceled")),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height:
                  MediaQuery.of(context).size.height *
                  0.3, // 30% of screen height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 194, 12, 67),
                    const Color.fromARGB(255, 115, 0, 95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Our Saving Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Consumer<TotalAmountProvider>(
                        builder: (context, totalAmountProvider, child) {
                          return Text(
                            'Rs.${totalAmountProvider.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Recent Income & Expenses",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color.fromARGB(255, 115, 0, 95),
                      tabs: [Tab(text: "Expenses"), Tab(text: "Income")],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Expenses Tab
                          ListView.builder(
                            itemCount:
                                _transactions
                                    .where((t) => t["type"] == "Expense")
                                    .length,
                            itemBuilder: (context, index) {
                              final expense =
                                  _transactions
                                      .where((t) => t["type"] == "Expense")
                                      .toList()[index];
                              return ListTile(
                                leading: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.red,
                                ),
                                title: Text(expense["reason"]),
                                subtitle: Text(expense["timestamp"]),
                                trailing: Text("- Rs.${expense["amount"]}"),
                              );
                            },
                          ),
                          // Income Tab
                          ListView.builder(
                            itemCount:
                                _transactions
                                    .where((t) => t["type"] == "Income")
                                    .length,
                            itemBuilder: (context, index) {
                              final income =
                                  _transactions
                                      .where((t) => t["type"] == "Income")
                                      .toList()[index];
                              return ListTile(
                                leading: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.green,
                                ),
                                title: Text(income["reason"]),
                                subtitle: Text(income["timestamp"]),
                                trailing: Text("+ Rs.${income["amount"]}"),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openBottomModalSheet,
        backgroundColor: Color.fromARGB(255, 115, 0, 95),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
