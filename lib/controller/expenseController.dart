import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseController extends GetxController {
  late final Future<Isar> _isarFuture;
  final RxList<Expense> expenses = <Expense>[].obs;

  @override
  void onInit() {
    super.onInit();
    _isarFuture = _openDB();
    _initialize(); // Start the chain after setting _isarFuture
  }

  Future<Isar> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([ExpenseSchema, TagSchema], directory: dir.path);
  }

  Future<void> _initialize() async {
    final isar = await _isarFuture;
    await _ensureDefaultTags(isar);
    await _loadExpenses(isar);
  }

  // --------------------------------
  // ---------- EXPENSES ------------
  // --------------------------------

  Future<void> _loadExpenses(Isar isar) async {
    final data = await isar.expenses.where().sortByTimeStampDesc().findAll();
    expenses.assignAll(data);
  }

  Future<void> addExpense(Expense expense) async {
    final isar = await _isarFuture;

    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
      await expense.tag.save();

      // await isar.expenses.clear();
    });

    expenses.insert(0, expense);
  }

  Future<List<Expense>> getAllExpenses() async {
    final isar = await _isarFuture;

    final expenses = await isar.expenses.where().findAll();

    return expenses;
  }

  // --------------------------------
  // ------------ TAGS --------------
  // --------------------------------

  Future<void> _ensureDefaultTags(Isar isar) async {
    final defaultTags = [
      {'name': 'Food', 'color': Colors.red, 'icon': 'fastfood'},
      {'name': 'Travel', 'color': Colors.blue, 'icon': 'flight'},
      {'name': 'Education', 'color': Colors.green, 'icon': 'school'},
      {'name': 'Daily items', 'color': Colors.orange, 'icon': 'shopping_cart'},
    ];

    for (final tagData in defaultTags) {
      final exists = await isar.tags
          .filter()
          .nameEqualTo(tagData['name'] as String)
          .findFirst();

      if (exists != null) continue;

      final tag = Tag()
        ..name = tagData['name'] as String
        ..colorValue = (tagData['color'] as Color).value
        ..icon = tagData['icon'] as String;

      await isar.writeTxn(() => isar.tags.put(tag));
    }
  }

  Future<List<Tag>> getAllTags() async {
    final isar = await _isarFuture;
    return await isar.tags.where().findAll();
  }

  Future<Map<Tag, double>> getTotalExpensePerTag() async {
    final isar = await _isarFuture;

    // Load all tags and expenses
    final expenses = await isar.expenses.where().findAll();
    final tags = await isar.tags.where().findAll();

    Map<Tag, double> totals = {};

    for (final tag in tags) {
      final matchingExpenses = expenses.where((expense) {
        return expense.tag.value?.id == tag.id;
      });

      final totalForTag = matchingExpenses.fold<double>(
        0.0,
        (sum, e) => sum + e.amount,
      );

      if (totalForTag > 0) {
        totals[tag] = totalForTag;
      }
    }

    return totals;
  }
}
