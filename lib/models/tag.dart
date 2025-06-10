import 'package:isar/isar.dart';

part 'tag.g.dart';

@Collection()
class Tag {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
  late int colorValue;
  String? icon;
}
