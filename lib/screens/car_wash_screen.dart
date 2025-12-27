import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../widgets/option_selector.dart';
import '../utils/reminder_helper.dart';

class CarWashScreen extends StatefulWidget {
  final CarWashMemory? existingMemory;

  const CarWashScreen({super.key, this.existingMemory});

  @override
  State<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends State<CarWashScreen> {
  String? _selectedMethod;
  DateTime? _selectedDate;
  CarWashMemory? _currentMemory;

  final List<String> _methods = ['hand', 'automatic', 'self'];

  @override
  void initState() {
    super.initState();
    if (widget.existingMemory != null) {
      _currentMemory = widget.existingMemory;
      setState(() {
        _selectedMethod = widget.existingMemory!.method;
        _selectedDate = widget.existingMemory!.createdAt;
      });
    }
  }

  Future<void> _save() async {
    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final oldMemory = _currentMemory ?? widget.existingMemory;
    final memory = CarWashMemory(
      id: oldMemory?.id,
      method: _selectedMethod,
      createdAt: _selectedDate ?? oldMemory?.createdAt ?? DateTime.now(),
    );

    if (oldMemory != null) {
      await provider.updateMemory(oldMemory, memory);
      _currentMemory = memory;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('세차 기록이 수정되었습니다'),
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
            content: Text('세차 기록이 저장되었습니다'),
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
    final provider = Provider.of<MemoryProvider>(context);
    final latest = provider.getLatestMemory(MemoryType.carWash) as CarWashMemory?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('세차'),
        actions: [
          if (_selectedMethod != null || widget.existingMemory != null)
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

            // Current status
            if (latest != null && widget.existingMemory == null) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_car_wash,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '마지막 세차',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Builder(
                            builder: (context) {
                              final days = ReminderHelper.daysSinceCarWash(latest);
                              if (days != null) {
                                return Text(
                                  '$days일 전',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Method selector
            OptionSelector<String?>(
              title: '세차 방법 (선택사항)',
              options: [
                OptionItem<String?>(value: null, label: '기록만 저장'),
                ..._methods.map((m) {
                  String label;
                  switch (m) {
                    case 'hand':
                      label = '손세차';
                      break;
                    case 'automatic':
                      label = '자동세차';
                      break;
                    case 'self':
                      label = '셀프세차';
                      break;
                    default:
                      label = m;
                  }
                  return OptionItem(value: m, label: label);
                }),
              ],
                    selectedValue: _selectedMethod,
                    onSelected: (value) {
                      setState(() {
                        _selectedMethod = value;
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

