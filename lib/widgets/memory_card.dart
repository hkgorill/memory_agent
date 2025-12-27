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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildSubtitle(context, theme),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeData theme) {
    if (memory == null) {
      return Text(
        '기록 없음',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }
        break;
      case MemoryType.beauty:
        if (memory is BeautyMemory) {
          final m = memory as BeautyMemory;
          final date = DateFormat('M월 d일').format(m.createdAt);
          String serviceLabel;
          switch (m.service) {
            case 'cut':
              serviceLabel = '컷트';
              break;
            case 'perm':
              serviceLabel = '펌';
              break;
            case 'color':
              serviceLabel = '염색';
              break;
            default:
              serviceLabel = m.service;
          }
          return Text(
            '$serviceLabel · $date',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              );
            } else {
              return Text(
                '다음 교체까지 $days일',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        }
        break;
    }

    final date = DateFormat('M월 d일').format(memory!.createdAt);
    return Text(
      date,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade700,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

