import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';

class CustomMemoryScreen extends StatefulWidget {
  final CustomMemory? existingMemory;

  const CustomMemoryScreen({
    super.key,
    this.existingMemory,
  });

  @override
  State<CustomMemoryScreen> createState() => _CustomMemoryScreenState();
}

class _CustomMemoryScreenState extends State<CustomMemoryScreen> {
  final _nameController = TextEditingController();
  String _memoryType = 'date'; // 'date' or 'option'
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    if (widget.existingMemory != null) {
      _nameController.text = widget.existingMemory!.name;
      _memoryType = widget.existingMemory!.payload['type'] ?? 'date';
      _selectedOption = widget.existingMemory!.payload['value'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이름을 입력해주세요'),
        ),
      );
      return;
    }

    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final memory = CustomMemory(
      id: widget.existingMemory?.id,
      name: _nameController.text.trim(),
      payload: {
        'type': _memoryType,
        if (_selectedOption != null) 'value': _selectedOption,
      },
      createdAt: widget.existingMemory?.createdAt,
    );

    if (widget.existingMemory != null) {
      await provider.updateMemory(widget.existingMemory!, memory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('커스텀 메모리가 수정되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      await provider.addMemory(memory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('커스텀 메모리가 저장되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('커스텀 메모리'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '예: 운동, 약 복용 등',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Memory type selector
            Text(
              '메모리 타입',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'date',
                  label: Text('날짜만'),
                ),
                ButtonSegment(
                  value: 'option',
                  label: Text('옵션 선택'),
                ),
              ],
              selected: {_memoryType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _memoryType = newSelection.first;
                  _selectedOption = null;
                });
              },
            ),
            const SizedBox(height: 24),

            // Option input (if option type)
            if (_memoryType == 'option') ...[
              Text(
                '옵션 값',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value.isEmpty ? null : value;
                  });
                },
                decoration: InputDecoration(
                  labelText: '옵션 값 입력',
                  hintText: '예: 완료, 미완료 등',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

