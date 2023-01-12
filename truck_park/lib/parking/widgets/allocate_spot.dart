import 'package:flutter/material.dart';
import 'package:truck_park/parking/model/parking_spot.dart';
import 'package:truck_park/parking/model/vehicle_register.dart';

class AllocateSpot extends StatefulWidget {
  final List<ParkingSpot> freeSpots;
  final Function(VehicleRegisterDTO vehicle) allocate;

  const AllocateSpot({
    super.key,
    required this.freeSpots,
    required this.allocate
  });

  @override
  State<AllocateSpot> createState() => _AllocateSpotState();
}

class _AllocateSpotState extends State<AllocateSpot> {
  TextEditingController plateController = TextEditingController();
  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    bool hasFreeSpots = widget.freeSpots.isNotEmpty;
    String dropValue = hasFreeSpots ? widget.freeSpots.first.name : '';

    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Form(
            child: TextFormField(
              key: const ValueKey('allocateFormField'),
              controller: plateController,
              onChanged: (value) {
                setState(() {
                  isValid = plateController.text.isNotEmpty && hasFreeSpots && plateController.text.length >= 7;
                });
              },
              enabled: hasFreeSpots,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                hintText: 'ex: WWW0909',
                label: Text('Placa'),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length < 7 && value.isNotEmpty) {
                  return 'A placa deve ter 7 digitos';
                } 
                return null;
              },
            ),
          ),
          const SizedBox(
            height: 12,
          ),
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
            items: widget.freeSpots.map((freeSpot) => freeSpot.name).map((name) => 
              DropdownMenuItem(
                key: UniqueKey(),
                value: name,
                child: Text(name),
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
                  key: const ValueKey('allocateBtn'),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Alocar'),
                  onPressed: isValid
                  ? () async => {
                    widget.allocate(
                      VehicleRegisterDTO(
                        plate: plateController.text.toUpperCase(),
                        spotName: dropValue,
                        createAt: DateTime.now().toString()
                      )
                    ),
                    plateController.clear()
                  }
                  : null
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}