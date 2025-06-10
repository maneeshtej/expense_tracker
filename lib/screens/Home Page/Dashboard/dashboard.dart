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
  List<Expense> _tagExpenses = [];
  Tag? _selectedTag;
  bool _loading = true;
  // int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadTagTotals();
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
    final expenses = all.where((e) => e.tag.value?.id == tag.id).toList();
    setState(() {
      _selectedTag = tag;
      _tagExpenses = expenses;
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
        // _touchedIndex = -1;
        return;
      }
      // _touchedIndex = response.touchedSection!.touchedSectionIndex;
    });
  }

  double get _totalSpent => _tagTotals.values.fold(0.0, (prev, e) => prev + e);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi User", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 30),
              Text(
                "Tag-wise Spending",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),

              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_tagTotals.isEmpty)
                const Text(
                  "No expenses to show",
                  style: TextStyle(color: Colors.white),
                )
              else ...[
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: PieChart(
                    PieChartData(
                      sections: _tagTotals.entries.map((entry) {
                        final tag = entry.key;
                        final amount = entry.value;
                        final percentage = (amount / _totalSpent * 100)
                            .toStringAsFixed(1);

                        return PieChartSectionData(
                          value: amount,
                          title: "${tag.name} \n$percentage%",
                          color: Color(tag.colorValue),
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          radius: 60,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          final section = response?.touchedSection;
                          final index = section?.touchedSectionIndex ?? -1;

                          if (index >= 0 && index < _tagTotals.length) {
                            final tag = _tagTotals.keys.elementAt(index);
                            _loadExpensesByTag(tag);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tagTotals.length,
                    itemBuilder: (context, index) {
                      final entry = _tagTotals.entries.elementAt(index);
                      final tag = entry.key;
                      final amount = entry.value;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Color(tag.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),

                            Text(
                              tag.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              " : ₹${amount.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 💰 Total spending summary
                Text(
                  "Total Spent: ₹${_totalSpent.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // 🧾 Selected tag expenses
                if (_selectedTag != null) ...[
                  Text(
                    "Expenses for '${_selectedTag!.name}'",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._tagExpenses.map((e) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${e.amount.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            e.note ?? "No note",
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
