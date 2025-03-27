class Expense {
  final String reason;
  final double amount;
  final DateTime date;

  Expense({required this.reason, required this.amount, required this.date});

  Map<String, dynamic> toJson() {
    return {'reason': reason, 'amount': amount, 'date': date.toIso8601String()};
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      reason: json['reason'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }
}
