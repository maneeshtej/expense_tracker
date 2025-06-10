import 'package:expense_tracker/models/tag.dart';
import 'package:isar/isar.dart';

part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement;

  late double amount;
  @Index()
  final tag = IsarLink<Tag>();

  @Index()
  late DateTime timeStamp;

  String? bankName;
  String? recieverName;

  String? note;

  bool isIncome = false;

  bool isSynced = false;
}
