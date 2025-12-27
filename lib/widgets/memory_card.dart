import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../utils/reminder_helper.dart';

class MemoryCard extends StatelessWidget {
  final Memory? memory;
  final MemoryType type;
  final VoidCallback onTap;
  final String title;
  final IconData icon;

  const MemoryCard({
    super.key,
    required this.memory,
    required this.type,
    required this.onTap,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildSubtitle(context, theme),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeData theme) {
    if (memory == null) {
      return Text(
        '기록 없음',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    switch (type) {
      case MemoryType.parking:
        if (memory is ParkingMemory) {
          final m = memory as ParkingMemory;
          String placeLabel;
          switch (m.place) {
            case 'home':
              placeLabel = '집';
              break;
            case 'office':
              placeLabel = '회사';
              break;
            case 'other':
              placeLabel = '기타';
              break;
            default:
              placeLabel = m.place;
          }
          final zoneText = m.zone != null ? ' ${m.zone}' : '';
          return Text(
            '$placeLabel · ${m.floor}$zoneText',
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }
        break;
      case MemoryType.beauty:
        if (memory is BeautyMemory) {
          final m = memory as BeautyMemory;
          final date = DateFormat('M월 d일').format(m.createdAt);
          return Text(
            '${m.service} · $date',
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }
        break;
      case MemoryType.razor:
        if (memory is RazorMemory) {
          final m = memory as RazorMemory;
          final days = ReminderHelper.daysUntilRazorReplacement(m);
          if (days != null) {
            if (days == 0) {
              return Text(
                '오늘 교체일',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              );
            } else {
              return Text(
                '다음 교체까지 $days일',
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            }
          }
        }
        break;
      case MemoryType.carWash:
        if (memory is CarWashMemory) {
          final m = memory as CarWashMemory;
          final days = ReminderHelper.daysSinceCarWash(m);
          if (days != null) {
            return Text(
              '$days일 전',
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          }
        }
        break;
      case MemoryType.custom:
        if (memory is CustomMemory) {
          final m = memory as CustomMemory;
          final date = DateFormat('M월 d일').format(m.createdAt);
          return Text(
            '$date',
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }
        break;
    }

    final date = DateFormat('M월 d일').format(memory!.createdAt);
    return Text(
      date,
      style: theme.textTheme.bodyMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

