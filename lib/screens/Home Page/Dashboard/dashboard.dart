import 'package:expense_tracker/controller/expenseController.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/tag.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();

  Map<Tag, double> _tagTotals = {};
  List<Expense> _expenses = [];
  List<Expense> _allExpenses = [];
  Tag? _selectedTag;
  bool _loading = true;
  bool _isTouched = false;
  // int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadTagTotals();
    _getAllExpenses();
  }

  Future<void> _loadTagTotals() async {
    final totals = await _expenseController.getTotalExpensePerTag();
    setState(() {
      _tagTotals = totals;
      _loading = false;
    });
  }

  Future<void> _loadExpensesByTag(Tag tag) async {
    final all = await _expenseController.getAllExpenses();

    if (_selectedTag != null && _selectedTag!.id == tag.id) {
      // Deselect and show all expenses
      setState(() {
        _selectedTag = null;
        _isTouched = false;
        _expenses = [];
        _allExpenses = all; // refresh all expenses
      });
    } else {
      final expenses = all.where((e) => e.tag.value?.id == tag.id).toList();
      setState(() {
        _selectedTag = tag;
        _expenses = expenses;
        _isTouched = true;
      });
    }
  }

  Future<void> _getAllExpenses() async {
    final allExpenses = await _expenseController.getAllExpenses();

    setState(() {
      _allExpenses = allExpenses;
    });
  }

  void handlePieChartSectionTouch(
    FlTouchEvent event,
    PieTouchResponse? response,
  ) {
    setState(() {
      if (!event.isInterestedForInteractions ||
          response == null ||
          response.touchedSection == null) {
        return;
      }
    });
  }

  double get _totalSpent => _tagTotals.values.fold(0.0, (prev, e) => prev + e);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi User",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pie Chart
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_tagTotals.isEmpty)
                const Text(
                  "No expenses to show",
                  style: TextStyle(color: Colors.white),
                )
              else ...[
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _tagTotals.entries.map((entry) {
                        final tag = entry.key;
                        final amount = entry.value;
                        final percentage = (amount / _totalSpent * 100)
                            .toStringAsFixed(1);
                        return PieChartSectionData(
                          value: amount,
                          title: "${tag.name}\n$percentage%",
                          color: Color(tag.colorValue),
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          radius: _selectedTag == tag ? 65 : 60,
                        );
                      }).toList(),

                      sectionsSpace: 1,
                      centerSpaceRadius: 60,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          final index =
                              response?.touchedSection?.touchedSectionIndex ??
                              -1;
                          if (index >= 0 && index < _tagTotals.length) {
                            final tag = _tagTotals.keys.elementAt(index);
                            _loadExpensesByTag(tag);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tag Legend
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tagTotals.length,
                    itemBuilder: (context, index) {
                      final entry = _tagTotals.entries.elementAt(index);
                      final tag = entry.key;
                      final amount = entry.value;

                      return GestureDetector(
                        onTap: () {
                          _loadExpensesByTag(tag);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedTag == tag
                                ? Colors.grey.shade300
                                : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Color(tag.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                "${tag.name}: ₹${amount.toInt()}",
                                style: TextStyle(
                                  color: _selectedTag == tag
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Spending Summary
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryColumn("Today", _totalSpent.toInt()),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade700,
                      ),
                      _buildSummaryColumn("Monthly", 2800),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Divider(),

                // Expense List
                expensesList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Column expensesList() {
    final finalExpenses = _isTouched ? _expenses : _allExpenses;
    return Column(
      spacing: 20,
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("History", style: TextStyle(fontSize: 30)),
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text("Filters", style: TextStyle(color: Colors.black)),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          children: finalExpenses.map((expense) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  "₹${expense.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  expense.tag.value?.name ?? "Unknown",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

Widget _buildSummaryColumn(String label, int amount) {
  return Column(
    children: [
      Text(
        "₹ $amount",
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "$label Spending",
        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      ),
    ],
  );
}
