import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:truck_park/parking/controller/parking_controller.dart';

import 'package:truck_park/parking/model/history.dart';
import 'package:truck_park/parking/model/parking_spot.dart';
import 'package:truck_park/parking/view/parking.dart';

import '../controller/parking_controller_test.mocks.dart';

@GenerateMocks([HiveInterface, Box])
void main() {
  MockHiveInterface mockHiveInterface = MockHiveInterface();
  MockBox mockHiveBox = MockBox();
  late ParkingController parkingController;

  List<History> listHistory = [];
  
  setUp(() async  {
    TestWidgetsFlutterBinding.ensureInitialized();
    when(mockHiveInterface.openBox(any)).thenAnswer((_) async => mockHiveBox);
    await mockHiveInterface.openBox('spotsBox');

    List<ParkingSpot> list = List.generate(
      12,
      (index) => ParkingSpot(
        id: index.toString(),
        name: (index < 6 ? 'A' : 'B') + index.toString(),
        vacancy: index == 0 ? false : true
      )
    );

    listHistory = List.generate(
      1,
      (index) => History(
        createAt: '',
        plate: 'WWW0909',
        spot: 'A0'
      )
    );

    when(mockHiveBox.clear()).thenAnswer((_) async => 0);
    when(mockHiveBox.get(any, defaultValue: [])).thenAnswer((_) => list);
    when(mockHiveBox.get(any)).thenAnswer((_) => listHistory);
    when(mockHiveInterface.box(any)).thenReturn(mockHiveBox);

    parkingController = ParkingController(mockHiveInterface);
  });

  testWidgets('Change tabs selection', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ParkingPage(controller: parkingController),
      )
    );

    await tester.tap(find.byKey(const ValueKey('alocar')));
    expect(parkingController.selectedTab, 0);

    await tester.tap(find.byKey(const ValueKey('desalocar')));
    expect(parkingController.selectedTab, 1);
    
    await tester.tap(find.byKey(const ValueKey('historico')));
    expect(parkingController.selectedTab, 2);
  });

  testWidgets('allocate spot and check history', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ParkingPage(controller: parkingController),
      )
    );

    var allocateBtn = find.byKey(const ValueKey('allocateBtn'));

    await tester.enterText(find.byKey(const ValueKey('allocateFormField')), 'WWW0909');
    await tester.ensureVisible(allocateBtn);
    await tester.tap(allocateBtn);

    expect(parkingController.getFilledSpots().isNotEmpty, true);
    expect(parkingController.getTodayHistory(), listHistory);
  });

  testWidgets('deallocate spot', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ParkingPage(controller: parkingController),
      )
    );

    await tester.tap(find.byKey(const ValueKey('desalocar')));
    await tester.pumpAndSettle();

    var deallocateBtn = find.byKey(const ValueKey('deallocateBtn'));

    await tester.ensureVisible(deallocateBtn);
    await tester.tap(deallocateBtn);

    expect(parkingController.getFilledSpots().isEmpty, true);
  });
}
