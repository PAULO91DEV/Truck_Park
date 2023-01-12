import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 2)
class History {
  @HiveField(0)
  String plate;

  @HiveField(1)
  String spot;

  @HiveField(2)
  String createAt;

  History({
    required this.plate,
    required this.spot,
    required this.createAt,
  });
}