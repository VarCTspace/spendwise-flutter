import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  final List<MoneyTransaction> _transactions = [];

  List<MoneyTransaction> get transactions =>
      List.unmodifiable(_transactions);

  double get totalIncome {
    return _transactions
        .where((item) => item.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((item) => !item.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpenses;

  Future<void> loadTransactions() async {
    final saved = await StorageService.loadTransactions();

    _transactions
      ..clear()
      ..addAll(saved);

    _transactions.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required bool isIncome,
    required DateTime date,
  }) async {
    final transaction = MoneyTransaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      isIncome: isIncome,
      date: date,
    );

    _transactions.insert(0, transaction);

    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((item) => item.id == id);

    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }
}
