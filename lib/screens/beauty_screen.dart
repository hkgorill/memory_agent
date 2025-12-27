import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../widgets/option_selector.dart';

class BeautyScreen extends StatefulWidget {
  final BeautyMemory? existingMemory;

  const BeautyScreen({super.key, this.existingMemory});

  @override
  State<BeautyScreen> createState() => _BeautyScreenState();
}

class _BeautyScreenState extends State<BeautyScreen> {
  String? _selectedService;
  DateTime? _selectedDate;
  BeautyMemory? _currentMemory;

  final List<String> _services = ['cut', 'perm', 'color'];

  @override
  void initState() {
    super.initState();
    if (widget.existingMemory != null) {
      _currentMemory = widget.existingMemory;
      setState(() {
        _selectedService = widget.existingMemory!.service;
        _selectedDate = widget.existingMemory!.createdAt;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedService == null) {
      return;
    }

    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final oldMemory = _currentMemory ?? widget.existingMemory;
    final memory = BeautyMemory(
      id: oldMemory?.id,
      service: _selectedService!,
      createdAt: _selectedDate ?? oldMemory?.createdAt ?? DateTime.now(),
    );

    if (oldMemory != null) {
      await provider.updateMemory(oldMemory, memory);
      _currentMemory = memory;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('미용 기록이 수정되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      await provider.addMemory(memory);
      _currentMemory = memory;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('미용 기록이 저장되었습니다'),
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
        title: const Text('미용실'),
        actions: [
          if (_selectedService != null)
            TextButton(
              onPressed: _save,
              child: const Text('저장'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selector (only in edit mode)
            if (widget.existingMemory != null) ...[
              Text(
                '날짜',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? widget.existingMemory!.createdAt,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('yyyy년 M월 d일').format(_selectedDate!)
                            : DateFormat('yyyy년 M월 d일').format(widget.existingMemory!.createdAt),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            OptionSelector<String>(
              title: '서비스',
              options: _services.map((s) {
                String label;
                switch (s) {
                  case 'cut':
                    label = '컷트';
                    break;
                  case 'perm':
                    label = '펌';
                    break;
                  case 'color':
                    label = '염색';
                    break;
                  default:
                    label = s;
                }
                return OptionItem(value: s, label: label);
              }).toList(),
              selectedValue: _selectedService,
              onSelected: (value) {
                setState(() {
                  _selectedService = value;
                });
                if (widget.existingMemory == null) {
                  _save(); // Auto-save only for new records
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

