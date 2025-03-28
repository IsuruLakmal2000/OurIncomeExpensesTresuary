import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtionshipincomeapp/providers/TotalAmountProvider.dart';
import 'package:realtionshipincomeapp/services/DatabaseService.dart';

class Incomeanaltycs extends StatelessWidget {
  final String title;
  final bool showTotalAmount;

  const Incomeanaltycs({
    Key? key,
    required this.title,
    this.showTotalAmount = false,
  }) : super(key: key);
  Future<String> _getUserName(String userId) async {
    final dbService = DatabaseService();
    return await dbService.getUserFirstName(userId); // Fetch user's first name
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser!.uid; // Get current user ID
    final totalIncomeFuture = Provider.of<TotalAmountProvider>(
      context,
    ).getUserIncome(currentUserId); // Get current user's income
    final otherUserIdFuture =
        Provider.of<TotalAmountProvider>(
          context,
        ).getOtherUserId(); // Get other user's ID

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current user's analytics
                      Text(
                        (FirebaseAuth.instance.currentUser?.displayName
                                ?.split(' ')
                                .first) ??
                            'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      FutureBuilder<double>(
                        future: totalIncomeFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Show a loading indicator while waiting
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            );
                          } else {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\Rs:${snapshot.data!.toStringAsFixed(2)}', // Display current user's total income
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      Text(
                        'total income',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Other user's analytics
                      FutureBuilder<String?>(
                        future: otherUserIdFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return Text(
                              'No Data',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            );
                          } else {
                            final otherUserId = snapshot.data!;
                            print("other user id --" + otherUserId);
                            final otherUserIncomeFuture =
                                Provider.of<TotalAmountProvider>(
                                  context,
                                  listen: false,
                                ).getUserIncome(otherUserId);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FutureBuilder<String>(
                                  future: _getUserName(otherUserId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Show loading indicator
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return Text(
                                        'Unknown',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                FutureBuilder<double>(
                                  future: otherUserIncomeFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Show loading indicator
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Error',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      );
                                    } else {
                                      return FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '\Rs:${snapshot.data!.toStringAsFixed(2)}', // Display other user's total income
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  'total income',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
