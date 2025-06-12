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

  Future<List<Expense>> getAllExpensesByDuration(
    String duration, {
    int? limit,
  }) async {
    final isar = await _isarFuture;
    final now = DateTime.now();

    late DateTime start;
    late DateTime end;

    switch (duration.toLowerCase()) {
      case "today":
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;

      case "weekly":
        final daysFromSunday = now.weekday % 7;
        start = DateTime(now.year, now.month, now.day - daysFromSunday);
        end = DateTime(
          now.year,
          now.month,
          now.day - daysFromSunday + 6,
          23,
          59,
          59,
          999,
        );
        break;

      case "monthly":
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;

      case "yearly":
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;

      default:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    }

    final query = isar.expenses
        .filter()
        .timeStampBetween(start, end)
        .sortByTimeStampDesc();

    // 👇 Directly return the final query after applying limit if needed
    if (limit != null) {
      return await query.limit(limit).findAll();
    } else {
      return await query.findAll();
    }
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

  Future<Map<Tag, double>> getAllTagsWithExpenseByDuration(
    String duration,
  ) async {
    final isar = await _isarFuture;
    final now = DateTime.now();

    late DateTime start;
    late DateTime end;

    switch (duration.toLowerCase()) {
      case "today":
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;

      case "weekly":
        final daysFromSunday = now.weekday % 7;
        start = DateTime(now.year, now.month, now.day - daysFromSunday);
        end = DateTime(
          now.year,
          now.month,
          now.day - daysFromSunday + 6,
          23,
          59,
          59,
          999,
        );
        break;

      case "monthly":
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;

      case "yearly":
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;

      default:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    }

    final expenses = await isar.expenses
        .filter()
        .timeStampBetween(start, end)
        .findAll();

    final Map<String, Tag> tagLookup = {};
    final Map<Tag, double> totals = {};

    for (final expense in expenses) {
      await expense.tag.load();
      final tag = expense.tag.value;
      if (tag == null) continue;

      final tagName = tag.name;

      if (tagName.toLowerCase() == "food") {
        print("Food tag amount before: ${totals[tagLookup[tagName]] ?? 0}");
        print("Current expense amount: ${expense.amount}");
      }

      if (tagLookup.containsKey(tagName)) {
        final existingTag = tagLookup[tagName]!;
        totals[existingTag] = (totals[existingTag] ?? 0) + expense.amount;
      } else {
        tagLookup[tagName] = tag;
        totals[tag] = expense.amount;
      }
    }

    return totals;
  }
}
