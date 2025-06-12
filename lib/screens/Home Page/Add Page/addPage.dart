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
      _currentTag = (_currentTag?.name == tag.name) ? null : tag;
    });
  }

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty || _currentTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount and select a tag')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount entered')));
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

    expense.tag.value = _currentTag!;
    await _expenseController.addExpense(expense);

    _amountController.clear();
    _bankNameController.clear();
    _receiverNameController.clear();
    _noteController.clear();

    setState(() {
      _currentTag = null;
      _isIncome = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense saved successfully!')),
    );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // optional: dark theme
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Add Expense"),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Purchase with power...",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              Text("Amount", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),
              Text("Tags", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),

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
                        onTap: () => _selectTag(tag),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade900,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.black,
                              width: isSelected ? 0.5 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            child: Text(
                              tag.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),
              Text("Bank Name", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              TextField(
                controller: _bankNameController,
                decoration: _inputDecoration(),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),
              Text(
                "Receiver Name",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _receiverNameController,
                decoration: _inputDecoration(),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),
              Text("Note", style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: _inputDecoration(),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Is Income?",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Switch(
                    value: _isIncome,
                    onChanged: (val) => setState(() => _isIncome = val),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Expense",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
