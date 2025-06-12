import 'package:expense_tracker/controller/expenseController.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/tag.dart';
import 'package:expense_tracker/screens/Home%20Page/Add%20Page/addPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final ScrollController _scrollController = ScrollController();
  String _selectedExpensesDurationToDisplay = "Today";
  List<Expense> _expenses = [];
  Map<Tag, dynamic> _tagExpenses = {};

  @override
  void initState() {
    super.initState();
    _getAllExpensesByTime();
    _getAllTagsWithExpensesByDuration();
  }

  Future<void> _getAllExpensesByTime() async {
    final expenses = await _expenseController.getAllExpensesByDuration(
      _selectedExpensesDurationToDisplay,
      limit: 20,
    );

    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _getAllTagsWithExpensesByDuration() async {
    final tagExpenses = await _expenseController
        .getAllTagsWithExpenseByDuration(_selectedExpensesDurationToDisplay);

    setState(() {
      _tagExpenses = tagExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hi User",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Icon(Icons.currency_rupee, size: 35),
                  ],
                ),
                Text(
                  " Will you save?",
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      // color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      spacing: 60,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "₹2,500",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Total Spent",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              "₹7,500",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Remaining Balance",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Spending",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Stack(
                          children: [
                            // Background bar (budget)
                            Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // Foreground bar (actual spending)
                            FractionallySizedBox(
                              widthFactor: 0.4, // 40% of budget spent
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "₹1,000 spent",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Budget: ₹2,500",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    children:
                        [
                          {
                            "label": "Add",
                            "icon": Icons.add,
                            "iconColor": Colors.green,
                          },
                          {
                            "label": "Income",
                            "icon": Icons.attach_money,
                            "iconColor": Colors.amber,
                          },
                          {
                            "label": "Calculator",
                            "icon": Icons.calculate,
                            "iconColor": Colors.redAccent,
                          },
                          {
                            "label": "Show All",
                            "icon": Icons.list,
                            "iconColor": Colors.blue,
                          },
                        ].map((option) {
                          final label = option["label"] as String;
                          final icon = option["icon"] as IconData;
                          final iconColor = option["iconColor"] as Color;

                          return GestureDetector(
                            onTap: () {
                              if (label == "Add") {
                                Get.to(() => const AddPage());
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(icon, color: iconColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
