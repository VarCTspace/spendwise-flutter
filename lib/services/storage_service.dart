import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _key = 'spendwise_transactions';

  static Future<void> saveTransactions(
      List<MoneyTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();

    final data = transactions.map((item) => item.toJson()).toList();

    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<List<MoneyTransaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_key);

    if (savedData == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(savedData);

      return decoded
          .map((item) => MoneyTransaction.fromJson(item))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
