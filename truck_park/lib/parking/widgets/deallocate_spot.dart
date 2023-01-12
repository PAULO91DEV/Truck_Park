import 'package:flutter/material.dart';
import 'package:truck_park/parking/model/parking_spot.dart';

class DeallocateSpot extends StatelessWidget {
  final List<ParkingSpot> filledSpots;
  final Function(String spot) deallocate;

  const DeallocateSpot({
    super.key,
    required this.deallocate,
    required this.filledSpots,
  });


  @override
  Widget build(BuildContext context) {
    bool hasFreeSpots = filledSpots.isNotEmpty;
    String dropValue = hasFreeSpots ? filledSpots.first.name : '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: UniqueKey(),
            isExpanded: true,
            isDense: true,
            value: dropValue,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))
              ),
            ),
            onChanged: hasFreeSpots
              ? (value) => dropValue = value!
              : null,
            items: filledSpots.map((freeSpot) => DropdownMenuItem(
                key: UniqueKey(),
                value: freeSpot.name,
                child: Text(freeSpot.plate ?? ''),
              )
            ).toList()
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const ValueKey('deallocateBtn'),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Dealocar'),
                  onPressed: dropValue.isNotEmpty  ? () => deallocate(dropValue) : null
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}