import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truck_park/parking/controller/parking_controller.dart';
import 'package:truck_park/parking/model/history.dart';
import 'package:truck_park/parking/model/parking_spot.dart';
import 'package:truck_park/parking/view/parking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive
    ..init(directory.path)
    ..registerAdapter(ParkingSpotAdapter())
    ..registerAdapter(HistoryAdapter());

  await Hive.openBox('spotsBox');
  await Hive.openBox('spotsHistoryBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ParkingPage(controller: ParkingController(Hive)),
    );
  }
}