import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../utils/reminder_helper.dart';

class RazorScreen extends StatefulWidget {
  final RazorMemory? existingMemory;

  const RazorScreen({super.key, this.existingMemory});

  @override
  State<RazorScreen> createState() => _RazorScreenState();
}

class _RazorScreenState extends State<RazorScreen> {
  DateTime? _selectedDate;
  RazorMemory? _currentMemory;

  @override
  void initState() {
    super.initState();
    if (widget.existingMemory != null) {
      _currentMemory = widget.existingMemory;
      setState(() {
        _selectedDate = widget.existingMemory!.lastChangedAt;
      });
    }
  }

  Future<void> _replaceRazor() async {
    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final oldMemory = _currentMemory ?? widget.existingMemory;
    final memory = RazorMemory(
      id: oldMemory?.id,
      lastChangedAt: _selectedDate ?? DateTime.now(),
      cycle: oldMemory?.cycle ?? 'monthly',
      notifyDay: oldMemory?.notifyDay ?? 1,
      createdAt: oldMemory?.createdAt ?? DateTime.now(),
    );

    if (oldMemory != null) {
      await provider.updateMemory(oldMemory, memory);
      _currentMemory = memory;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('면도날 교체가 수정되었습니다'),
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
            content: Text('면도날 교체가 기록되었습니다'),
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
    final latest = widget.existingMemory ?? provider.getLatestMemory(MemoryType.razor) as RazorMemory?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('면도날 교체'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current status
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.refresh,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  if (latest != null) ...[
                    Text(
                      widget.existingMemory != null ? '교체일' : '마지막 교체일',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy년 M월 d일').format(
                        _selectedDate ?? latest.lastChangedAt,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final days = ReminderHelper.daysUntilRazorReplacement(latest);
                        if (days == null) {
                          return const SizedBox.shrink();
                        }
                        if (days == 0) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '오늘 교체일입니다',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          return Text(
                            '다음 교체까지 $days일',
                            style: theme.textTheme.titleMedium,
                          );
                        }
                      },
                    ),
                  ] else ...[
                    Text(
                      '아직 기록이 없습니다',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Date selector (only in edit mode)
            if (widget.existingMemory != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          initialDate: _selectedDate ?? widget.existingMemory!.lastChangedAt,
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
                                  : DateFormat('yyyy년 M월 d일').format(widget.existingMemory!.lastChangedAt),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Replace button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _replaceRazor,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    widget.existingMemory != null ? '수정' : '교체함',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

