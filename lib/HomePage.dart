import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtionshipincomeapp/widgets/IncomeAnaltycs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:realtionshipincomeapp/services/AuthService.dart';
import 'package:realtionshipincomeapp/services/DatabaseService.dart';
import 'package:provider/provider.dart';
import 'package:realtionshipincomeapp/providers/TotalAmountProvider.dart';
import 'package:realtionshipincomeapp/widgets/ConfirmDialog.dart';
import 'package:realtionshipincomeapp/widgets/IncomeTab.dart';
import 'package:realtionshipincomeapp/widgets/ExpenseTab.dart';
import 'package:realtionshipincomeapp/widgets/AccountCard.dart';

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

  Future<String> _getUserName(String userId) async {
    final dbService = DatabaseService();
    return await dbService.getUserFirstName(userId); // Fetch user's first name
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
                          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                          type: selectedType!,
                          reason: reason,
                          amount: double.parse(amount),
                        );
                        await _fetchTransactions(); // Refresh transactions
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
            Icon(Icons.add_ic_call),
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
                    FutureBuilder<String?>(
                      future:
                          Provider.of<TotalAmountProvider>(
                            context,
                            listen: false,
                          ).getOtherUserId(), // Fetch other user's ID
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          );
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text(
                            'Unknown',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          );
                        } else {
                          final otherUserId = snapshot.data!;
                          return FutureBuilder<String>(
                            future: _getUserName(
                              otherUserId,
                            ), // Fetch other user's name
                            builder: (context, nameSnapshot) {
                              if (nameSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  'Loading...',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                );
                              } else if (nameSnapshot.hasError ||
                                  !nameSnapshot.hasData) {
                                return Text(
                                  'Unknown',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                );
                              } else {
                                return Text(
                                  nameSnapshot.data!,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
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
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.25, // 30% of screen height
              child: PageView(
                physics: ScrollPhysics(),
                controller: PageController(viewportFraction: 1),
                children: [
                  AccountCard(),
                  Incomeanaltycs(title: "Isuru", showTotalAmount: false),
                ],
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
                          ExpenseTab(
                            transactions: _transactions,
                            fetchTransactions: _fetchTransactions,
                            deleteTransaction:
                                _databaseService.deleteTransaction,
                          ),
                          IncomeTab(
                            transactions: _transactions,
                            fetchTransactions: _fetchTransactions,
                            deleteTransaction:
                                _databaseService.deleteTransaction,
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
