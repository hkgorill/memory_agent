import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../utils/reminder_helper.dart';

class ReminderBanner extends StatelessWidget {
  final RazorMemory? razorMemory;
  final VoidCallback onDismiss;

  const ReminderBanner({
    super.key,
    required this.razorMemory,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (razorMemory == null) return const SizedBox.shrink();

    final shouldShow = ReminderHelper.shouldShowRazorReminder(razorMemory);
    if (!shouldShow) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '면도날 교체 알림',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '오늘은 면도날을 교체할 날입니다',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

