import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:truck_park/parking/controller/parking_controller.dart';
import 'package:truck_park/parking/model/history.dart';
import 'package:truck_park/parking/model/parking_spot.dart';
import 'package:truck_park/parking/model/vehicle_register.dart';

import 'parking_controller_test.mocks.dart';

@GenerateMocks([HiveInterface, Box])
void main() {
  MockHiveInterface mockHiveInterface = MockHiveInterface();
  MockBox mockHiveBox = MockBox();
  late ParkingController parkingController;

  setUp(() async  {
    TestWidgetsFlutterBinding.ensureInitialized();
    when(mockHiveInterface.openBox(any)).thenAnswer((_) async => mockHiveBox);
    await mockHiveInterface.openBox('spotsBox');

    List<ParkingSpot> list = List.generate(
      12,
      (index) => ParkingSpot(
        id: index.toString(),
        name: (index < 6 ? 'A' : 'B') + index.toString(),
        vacancy: true
      )
    );

    List<History> listHistory = List.generate(
      12,
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
  
  test('test get spots from hive', () async {    
    parkingController.getSpots();

    verify(mockHiveBox.get('spots', defaultValue: []));
  });

  test('test get freeSpots', () {
    expect(parkingController.getFreeSpots(), []);
  });

  test('test get filledSpots', () {
    expect(parkingController.getFilledSpots(), []);
  });

  test('test allocateSpot', () {
    parkingController.getSpots();
    parkingController.allocateSpot(VehicleRegisterDTO(createAt: '', plate: 'WWW0909', spotName: 'A0'));

    verify(mockHiveBox.get('spots', defaultValue: []));
  });

  test('test deallocateSpot', () {
    parkingController.getSpots();
    parkingController.deallocateSpot('A0');

    verify(mockHiveBox.get('spots', defaultValue: []));
  });

  test('test getTodayHistory', () {
    expect(parkingController.getTodayHistory().isNotEmpty, true);
  });

  tearDown(() => {
    reset(mockHiveInterface),
    reset(mockHiveBox),
  });
}
