import 'package:hive/hive.dart';

part 'parking_spot.g.dart';

@HiveType(typeId: 1)
class ParkingSpot {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? plate;

  @HiveField(3)
  bool vacancy;

  ParkingSpot({
    this.plate,
    required this.id,
    required this.name,
    required this.vacancy
  });
}