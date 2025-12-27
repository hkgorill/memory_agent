import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/memory.dart';
import '../providers/memory_provider.dart';

class ParkingScreen extends StatefulWidget {
  final ParkingMemory? existingMemory;

  const ParkingScreen({super.key, this.existingMemory});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  String? _selectedPlace;
  String? _selectedFloor;
  final TextEditingController _zoneController = TextEditingController();
  String? _zoneImagePath;
  ParkingMemory? _currentMemory;

  final List<Map<String, String>> _places = [
    {'value': 'home', 'label': '집'},
    {'value': 'office', 'label': '회사'},
    {'value': 'other', 'label': '기타'},
  ];

  final List<String> _floors = [
    'B5',
    'B4',
    'B3',
    'B2',
    'B1',
    '1F',
    '2F',
    '3F',
    '4F',
    '5F',
    '6F',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingMemory != null) {
      _currentMemory = widget.existingMemory;
      setState(() {
        _selectedPlace = widget.existingMemory!.place;
        _selectedFloor = widget.existingMemory!.floor;
        _zoneController.text = widget.existingMemory!.zone ?? '';
        _zoneImagePath = widget.existingMemory!.zoneImagePath;
      });
    } else {
      _loadLatestMemory();
    }
  }

  @override
  void dispose() {
    _zoneController.dispose();
    super.dispose();
  }

  void _loadLatestMemory() {
    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final latest = provider.getLatestMemory(MemoryType.parking);
    if (latest is ParkingMemory) {
      setState(() {
        _selectedPlace = latest.place;
        _selectedFloor = latest.floor;
        _zoneController.text = latest.zone ?? '';
        _zoneImagePath = latest.zoneImagePath;
      });
    }
  }

  Future<String> _saveImageToLocal(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, 'parking_images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final savedImage = await imageFile.copy(path.join(imageDir.path, fileName));
    return savedImage.path;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final savedPath = await _saveImageToLocal(File(image.path));
        setState(() {
          _zoneImagePath = savedPath;
        });
        _save();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final savedPath = await _saveImageToLocal(File(image.path));
        setState(() {
          _zoneImagePath = savedPath;
        });
        _save();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 촬영 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _zoneImagePath = null;
    });
    _save();
  }

  Future<void> _save({bool shouldPop = false}) async {
    if (_selectedPlace == null || _selectedFloor == null) {
      return;
    }

    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final oldMemory = _currentMemory ?? widget.existingMemory;
    final zoneText = _zoneController.text.trim();
    final memory = ParkingMemory(
      id: oldMemory?.id,
      place: _selectedPlace!,
      floor: _selectedFloor!,
      zone: zoneText.isEmpty ? null : zoneText,
      zoneImagePath: _zoneImagePath,
      createdAt: oldMemory?.createdAt,
    );

    if (oldMemory != null) {
      await provider.updateMemory(oldMemory, memory);
      _currentMemory = memory;
      if (mounted && shouldPop) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('주차 위치가 수정되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      await provider.addMemory(memory);
      _currentMemory = memory;
      if (mounted && shouldPop) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('주차 위치가 저장되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }

    if (shouldPop && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주차 위치'),
        actions: [
          if (_selectedPlace != null && _selectedFloor != null)
            TextButton(
              onPressed: () => _save(shouldPop: true),
              child: const Text('저장'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place dropdown
            DropdownButtonFormField<String>(
              value: _selectedPlace,
              decoration: InputDecoration(
                labelText: '장소',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _places.map((place) {
                return DropdownMenuItem<String>(
                  value: place['value'],
                  child: Text(place['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlace = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Floor dropdown
            if (_selectedPlace != null)
              DropdownButtonFormField<String>(
                value: _selectedFloor,
                decoration: InputDecoration(
                  labelText: '층',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _floors.map((floor) {
                  return DropdownMenuItem<String>(
                    value: floor,
                    child: Text(floor),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFloor = value;
                  });
                  _save(); // 층 선택 시 자동 저장
                },
              ),
            const SizedBox(height: 24),

            // Zone section (optional)
            if (_selectedFloor != null) ...[
              Text(
                '구역 (선택사항)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Zone text input
              TextField(
                controller: _zoneController,
                decoration: InputDecoration(
                  labelText: '구역 입력',
                  hintText: '예: A-123, 3번 구역 등',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _save(); // 텍스트 변경 시 자동 저장
                },
              ),
              const SizedBox(height: 16),

              // Image section
              Text(
                '사진 (선택사항)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Image preview and buttons
              if (_zoneImagePath != null && File(_zoneImagePath!).existsSync())
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_zoneImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('갤러리에서 선택'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('사진 촬영'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
