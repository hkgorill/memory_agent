import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../widgets/option_selector.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  String? _selectedPlace;
  String? _selectedFloor;
  String? _selectedZone;

  final List<String> _places = ['home', 'office', 'other'];
  final List<String> _floors = [
    'B3',
    'B2',
    'B1',
    '1F',
    '2F',
    '3F',
    '4F',
    '5F',
    '6F',
    '7F',
    '8F',
    '9F',
    '10F',
  ];
  final List<String> _zones = [
    ...List.generate(26, (i) => String.fromCharCode(65 + i)), // A-Z
    ...List.generate(20, (i) => '${i + 1}'), // 1-20
  ];

  @override
  void initState() {
    super.initState();
    _loadLatestMemory();
  }

  void _loadLatestMemory() {
    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final latest = provider.getLatestMemory(MemoryType.parking);
    if (latest is ParkingMemory) {
      setState(() {
        _selectedPlace = latest.place;
        _selectedFloor = latest.floor;
        _selectedZone = latest.zone;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedPlace == null || _selectedFloor == null || _selectedZone == null) {
      return;
    }

    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final memory = ParkingMemory(
      place: _selectedPlace!,
      floor: _selectedFloor!,
      zone: _selectedZone!,
    );

    await provider.addMemory(memory);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주차 위치가 저장되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주차 위치'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place selector
            OptionSelector<String>(
              title: '장소',
              options: _places.map((p) {
                String label;
                switch (p) {
                  case 'home':
                    label = '집';
                    break;
                  case 'office':
                    label = '회사';
                    break;
                  case 'other':
                    label = '기타';
                    break;
                  default:
                    label = p;
                }
                return OptionItem(value: p, label: label);
              }).toList(),
              selectedValue: _selectedPlace,
              onSelected: (value) {
                setState(() {
                  _selectedPlace = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Floor selector
            if (_selectedPlace != null)
              OptionSelector<String>(
                title: '층',
                options: _floors.map((f) => OptionItem(value: f, label: f)).toList(),
                selectedValue: _selectedFloor,
                onSelected: (value) {
                  setState(() {
                    _selectedFloor = value;
                  });
                },
              ),
            const SizedBox(height: 16),

            // Zone selector
            if (_selectedFloor != null)
              OptionSelector<String>(
                title: '구역',
                options: _zones.map((z) => OptionItem(value: z, label: z)).toList(),
                selectedValue: _selectedZone,
                onSelected: (value) {
                  setState(() {
                    _selectedZone = value;
                  });
                  _save(); // Auto-save on zone selection
                },
              ),
          ],
        ),
      ),
    );
  }
}

