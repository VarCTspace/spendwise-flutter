class MoneyTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final DateTime date;

  MoneyTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
    };
  }

  factory MoneyTransaction.fromJson(Map<String, dynamic> json) {
    return MoneyTransaction(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      isIncome: json['isIncome'],
      date: DateTime.parse(json['date']),
    );
  }
}
