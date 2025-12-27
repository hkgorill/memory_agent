import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../utils/reminder_helper.dart';

class RazorScreen extends StatelessWidget {
  const RazorScreen({super.key});

  Future<void> _replaceRazor(BuildContext context) async {
    final provider = Provider.of<MemoryProvider>(context, listen: false);
    final memory = RazorMemory(
      lastChangedAt: DateTime.now(),
    );

    await provider.addMemory(memory);

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('면도날 교체가 기록되었습니다'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<MemoryProvider>(context);
    final latest = provider.getLatestMemory(MemoryType.razor) as RazorMemory?;

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
                      '마지막 교체일',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy년 M월 d일').format(latest.lastChangedAt),
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

            // Replace button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _replaceRazor(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    '교체함',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

