import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truck_park/parking/controller/parking_controller.dart';
import 'package:truck_park/parking/model/history.dart';
import 'package:truck_park/parking/widgets/allocate_spot.dart';
import 'package:truck_park/parking/widgets/deallocate_spot.dart';

class ParkingPage extends StatefulWidget {
  final ParkingController controller;

  const ParkingPage({super.key, required this.controller});

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  late ParkingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    _controller.getSpots();
  }

  @override
  Widget build(BuildContext context) {
    Widget space(
        {required String spaceNumber, required bool vacancy, String? plate}) {
      return Container(
        height: 142,
        width: 124,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
            color: vacancy ? Colors.transparent : Colors.redAccent,
            border: const Border.symmetric(
                vertical: BorderSide(color: Colors.white, width: 4))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(spaceNumber),
              Text(
                plate ?? '',
                style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraint) => SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/parking.png'),
                          fit: BoxFit.fill)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _controller.spacesAUncovered
                              .map((e) => Expanded(
                                  child: space(
                                      spaceNumber: e.name,
                                      vacancy: e.vacancy,
                                      plate: e.plate)))
                              .toList(),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _controller.spacesBCovered
                              .map((e) => Expanded(
                                  child: space(
                                      spaceNumber: e.name,
                                      vacancy: e.vacancy,
                                      plate: e.plate)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                CupertinoSegmentedControl(
                  groupValue: _controller.selectedTab,
                  onValueChanged: (int value) {
                    setState(() {
                      _controller.setSelectedTab(value);
                    });
                  },
                  children: const {
                    0: Padding(
                      key: ValueKey('alocar'),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      child: Text('Alocar'),
                    ),
                    1: Padding(
                      key: ValueKey('desalocar'),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      child: Text('Desalocar'),
                    ),
                    2: Padding(
                      key: ValueKey('historico'),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      child: Text('Histórico'),
                    )
                  },
                ),
                _controller.selectedTab == 0
                    ? AllocateSpot(
                        key: const ValueKey('allocateSpot'),
                        freeSpots: _controller.getFreeSpots(),
                        allocate: (vehicle) async {
                          await _controller.allocateSpot(vehicle);
                          setState(() {});
                        })
                    : _controller.selectedTab == 1
                        ? DeallocateSpot(
                            key: const ValueKey('deallocateSpot'),
                            filledSpots: _controller.getFilledSpots(),
                            deallocate: (String spot) {
                              setState(() {
                                _controller.deallocateSpot(spot);
                              });
                            },
                          )
                        : Column(
                            key: const ValueKey('history'),
                            children: [
                              _controller.getTodayHistory().isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _controller
                                                    .getFilledSpots()
                                                    .isNotEmpty
                                                ? null
                                                : _controller.exportHistoryCsv,
                                            label: const Text('Fechar dia'),
                                            icon: const Icon(
                                                Icons.import_export_sharp),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                height: constraint.maxWidth - 124,
                                child: ListView.builder(
                                  itemCount:
                                      _controller.getTodayHistory().length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    History history =
                                        _controller.getTodayHistory()[index];
                                    return ListTile(
                                      title: Text(history.plate),
                                      subtitle: Text(history.createAt),
                                      trailing: Text(history.spot),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
