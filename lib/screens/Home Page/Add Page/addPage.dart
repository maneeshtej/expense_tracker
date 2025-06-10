import 'package:expense_tracker/controller/expenseController.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ExpenseController _expenseController = Get.find<ExpenseController>();

  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _noteController = TextEditingController();

  List<Tag> _tags = [];
  Tag? _currentTag;

  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    getAllTags();
  }

  Future<void> getAllTags() async {
    final tags = await _expenseController.getAllTags();

    tags.add(
      Tag()
        ..name = "+"
        ..icon = "add",
    );

    setState(() {
      _tags = tags;
    });
  }

  Future<void> _selectTag(Tag tag) async {
    setState(() {
      if (_currentTag == null) {
        _currentTag = tag;
      } else if (_currentTag?.name == tag.name) {
        _currentTag = null;
      } else {
        _currentTag = tag;
      }
    });
  }

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty || _currentTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter amount and select a tag')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid amount entered')));
      return;
    }

    final expense = Expense()
      ..amount = amount
      ..timeStamp = DateTime.now()
      ..bankName = _bankNameController.text.isEmpty
          ? null
          : _bankNameController.text
      ..recieverName = _receiverNameController.text.isEmpty
          ? null
          : _receiverNameController.text
      ..note = _noteController.text.isEmpty ? null : _noteController.text
      ..isIncome = _isIncome;

    // Link the selected tag
    expense.tag.value = _currentTag!;

    await _expenseController.addExpense(expense);

    // Clear inputs after saving
    _amountController.clear();
    _bankNameController.clear();
    _receiverNameController.clear();
    _noteController.clear();
    setState(() {
      _currentTag = null;
      _isIncome = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Expense saved successfully!')));
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade700, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade700, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade700, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Expense",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                "Purchase with power...",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              SizedBox(height: 30),
              // Amount Field
              Text("Amount", style: Theme.of(context).textTheme.labelSmall),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(),
              ),

              SizedBox(height: 20),

              // Tags selector (same style as before)
              Text("Tags", style: Theme.of(context).textTheme.labelSmall),
              SizedBox(height: 10),
              if (_tags.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    itemCount: _tags.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      final isSelected = _currentTag?.name == tag.name;
                      return GestureDetector(
                        onTap: () {
                          _selectTag(tag);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 0, right: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade900,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 0.5)
                                : Border.all(color: Colors.black, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            child: Text(
                              tag.name,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(height: 20),

              // Bank Name
              Text("Bank Name", style: Theme.of(context).textTheme.labelSmall),
              SizedBox(height: 10),
              TextField(
                controller: _bankNameController,
                decoration: _inputDecoration(),
              ),

              SizedBox(height: 20),

              // Receiver Name
              Text(
                "Receiver Name",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _receiverNameController,
                decoration: _inputDecoration(),
              ),

              SizedBox(height: 20),

              // Note
              Text("Note", style: Theme.of(context).textTheme.labelSmall),
              SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: _inputDecoration(),
              ),

              SizedBox(height: 20),

              // Income Toggle
              Row(
                children: [
                  Text(
                    "Is Income?",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Switch(
                    value: _isIncome,
                    onChanged: (val) {
                      setState(() {
                        _isIncome = val;
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    _saveExpense();
                  },
                  child: Text("Save Expense", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
