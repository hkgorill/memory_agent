import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../widgets/option_selector.dart';
import '../utils/reminder_helper.dart';

class CarWashScreen extends StatefulWidget {
  const CarWashScreen({super.key});

  @override
  State<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends State<CarWashScreen> {
  String? _selectedMethod;

  final List<String> _methods = ['hand', 'automatic', 'self'];

  Future<void> _save() async {
    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final memory = CarWashMemory(
      method: _selectedMethod,
    );

    await provider.addMemory(memory);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('세차 기록이 저장되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status
            if (latest != null) ...[
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
                _save(); // Auto-save on selection
              },
            ),
          ],
        ),
      ),
    );
  }
}

