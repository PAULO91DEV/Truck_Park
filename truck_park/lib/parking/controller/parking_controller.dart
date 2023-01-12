import 'dart:io';

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:truck_park/parking/model/history.dart';
import 'package:truck_park/parking/model/parking_spot.dart';
import 'package:truck_park/parking/model/vehicle_register.dart';
import 'package:pdf/widgets.dart' as pw;

class ParkingController {
  late Box<dynamic> spotsBox;
  late Box<dynamic> spotsHistoryBox;

  ParkingController(HiveInterface hive) {
    spotsBox = hive.box('spotsBox');
    spotsHistoryBox = hive.box('spotsHistoryBox');
    
    spotsBox.clear();
    spotsBox.put(
      'spots',
      List.generate(
        12,
        (index) => ParkingSpot(
          id: index.toString(),
          name: (index < 6 ? 'A' : 'B') + index.toString(),
          vacancy: true
        )
      )
    );
  }

  List<ParkingSpot> spacesAUncovered = [];
  List<ParkingSpot> spacesBCovered = [];

  int selectedTab = 0;
  void setSelectedTab(int tab) => selectedTab = tab;

  void getSpots() async {
    List<ParkingSpot> spotsList = spotsBox.get('spots', defaultValue: []);

    spacesAUncovered = spotsList.where((ParkingSpot spot) => spot.name.contains('A')).toList();
    spacesBCovered = spotsList.where((ParkingSpot spot) => spot.name.contains('B')).toList();
  }

  List<ParkingSpot> getFreeSpots() {
    return [...spacesAUncovered, ...spacesBCovered].where((ParkingSpot spot) => spot.vacancy).toList();
  }

  List<ParkingSpot> getFilledSpots() {
    return [...spacesAUncovered, ...spacesBCovered].where((ParkingSpot spot) => spot.vacancy == false).toList();
  }

  Future<void> allocateSpot(VehicleRegisterDTO vehicle) async {
    List<ParkingSpot> spots = [...spacesAUncovered, ...spacesBCovered];
    List<ParkingSpot> spotsList = spots.map((ParkingSpot spot) {
      if (spot.name == vehicle.spotName) {
        spot.vacancy = false;
        spot.plate = vehicle.plate;
      }

      return spot;
    }).toList();

    spotsBox.put('spots', spotsList);
    
    addHistory(
      History(
        plate: vehicle.plate,
        spot: "Entrou na vaga ${vehicle.spotName}",
        createAt: DateFormat('dd/MM/yyyy - hh:mm').format(DateTime.now())
      )
    );
    getSpots();
  }

  void deallocateSpot(String spotName) {
    String? plate = '';
    List<ParkingSpot> spots = [...spacesAUncovered, ...spacesBCovered];
    List<ParkingSpot> spotsList = spots.map((ParkingSpot spot) {
      if (spot.name == spotName) {
        plate = spot.plate;
        spot.vacancy = true;
        spot.plate = null;
      }

      return spot;
    }).toList();

    spotsBox.put('spots', spotsList);
    
    addHistory(
      History(
        plate: plate ?? '',
        spot: "Deixou a vaga $spotName",
        createAt: DateFormat('dd/MM/yyyy - hh:mm').format(DateTime.now())
      )
    );
    getSpots();
  }

  List<History> getTodayHistory() {
    String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    
    if (spotsHistoryBox.get(now) == null) {
      spotsHistoryBox.put(now, <History>[]);
    }
    List<dynamic> list = spotsHistoryBox.get(now);
    List<History> historyList = list.cast<History>();

    return historyList;
  }

  void addHistory(History history) {
    String now = DateFormat('dd/MM/yyyy').format(DateTime.now());

    if (spotsHistoryBox.get(now) == null) {
      spotsHistoryBox.put(now, <History>[]);
    }
    
    List<dynamic> list = spotsHistoryBox.get(now);
    List<History> historyList = list.cast<History>();

    historyList.add(history);
    spotsHistoryBox.put(now, historyList);
  }

  Future<void> exportHistoryCsv() async {
    String now = DateFormat('dd/MM/yyyy').format(DateTime.now());
    
    List<dynamic> list = spotsHistoryBox.get(now);
    List<History> historyList = list.cast<History>();

     final pdf = pw.Document();

     pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            children: historyList.map((e) =>
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(e.createAt),
                    ),
                    pw.Expanded(
                      child: pw.Text(e.plate),
                    ),
                    pw.Expanded(
                      child: pw.Text(e.spot),
                    ),
                  ]
                )
              )
            )
            .toList()
          ),
        ),
      );

    File file = File(await getFilePath(DateFormat('dd-MM-yyyy').format(DateTime.now())));
    await file.writeAsBytes(await pdf.save());
  }

  Future<String> getFilePath(String fileName) async {
    Directory? appDocumentsDirectory = Directory('/storage/emulated/0/Download');
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/$fileName.pdf';

    return filePath;
  }
}