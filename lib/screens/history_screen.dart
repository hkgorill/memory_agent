import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../utils/reminder_helper.dart';
import 'parking_screen.dart';
import 'beauty_screen.dart';
import 'razor_screen.dart';
import 'car_wash_screen.dart';
import 'custom_memory_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MemoryProvider>(
      builder: (context, provider, child) => DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('전체 히스토리'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '주차'),
              Tab(text: '미용실'),
              Tab(text: '면도날'),
              Tab(text: '세차'),
              Tab(text: '커스텀'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildParkingHistory(context, provider, theme),
            _buildBeautyHistory(context, provider, theme),
            _buildRazorHistory(context, provider, theme),
            _buildCarWashHistory(context, provider, theme),
            _buildCustomHistory(context, provider, theme),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildParkingHistory(
    BuildContext context,
    MemoryProvider provider,
    ThemeData theme,
  ) {
    final memories = provider.getMemoriesByType(MemoryType.parking);

    if (memories.isEmpty) {
      return Center(
        child: Text(
          '기록이 없습니다',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index] as ParkingMemory;
        final date = DateFormat('yyyy년 M월 d일 HH:mm').format(memory.createdAt);
        String placeLabel;
        switch (memory.place) {
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
            placeLabel = memory.place;
        }
        final zoneText = memory.zone != null ? ' ${memory.zone}' : '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.local_parking,
              color: theme.colorScheme.primary,
            ),
            title: Text('${memory.floor}$zoneText'),
            subtitle: Text('$placeLabel · $date'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ParkingScreen(existingMemory: memory),
                    ),
                  );
                  if (context.mounted) {
                    provider.loadMemories();
                  }
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('이 기록을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteMemory(memory);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기록이 삭제되었습니다')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeautyHistory(
    BuildContext context,
    MemoryProvider provider,
    ThemeData theme,
  ) {
    final memories = provider.getMemoriesByType(MemoryType.beauty);

    if (memories.isEmpty) {
      return Center(
        child: Text(
          '기록이 없습니다',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index] as BeautyMemory;
        final date = DateFormat('yyyy년 M월 d일 HH:mm').format(memory.createdAt);
        String serviceLabel;
        switch (memory.service) {
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
            serviceLabel = memory.service;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.content_cut,
              color: theme.colorScheme.primary,
            ),
            title: Text(serviceLabel),
            subtitle: Text(date),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  // Beauty screen doesn't support edit mode yet, show message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('미용실 기록은 수정할 수 없습니다. 새로 기록해주세요.')),
                    );
                  }
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('이 기록을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteMemory(memory);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기록이 삭제되었습니다')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRazorHistory(
    BuildContext context,
    MemoryProvider provider,
    ThemeData theme,
  ) {
    final memories = provider.getMemoriesByType(MemoryType.razor);

    if (memories.isEmpty) {
      return Center(
        child: Text(
          '기록이 없습니다',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index] as RazorMemory;
        final date = DateFormat('yyyy년 M월 d일 HH:mm').format(memory.lastChangedAt);
        final days = ReminderHelper.daysUntilRazorReplacement(memory);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.refresh,
              color: theme.colorScheme.primary,
            ),
            title: const Text('교체일'),
            subtitle: Text('$date${days != null ? ' · 다음 교체까지 $days일' : ''}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('이 기록을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteMemory(memory);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기록이 삭제되었습니다')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarWashHistory(
    BuildContext context,
    MemoryProvider provider,
    ThemeData theme,
  ) {
    final memories = provider.getMemoriesByType(MemoryType.carWash);

    if (memories.isEmpty) {
      return Center(
        child: Text(
          '기록이 없습니다',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index] as CarWashMemory;
        final date = DateFormat('yyyy년 M월 d일 HH:mm').format(memory.createdAt);
        final days = ReminderHelper.daysSinceCarWash(memory);
        String methodLabel = '기록만';
        if (memory.method != null) {
          switch (memory.method) {
            case 'hand':
              methodLabel = '손세차';
              break;
            case 'automatic':
              methodLabel = '자동세차';
              break;
            case 'self':
              methodLabel = '셀프세차';
              break;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.local_car_wash,
              color: theme.colorScheme.primary,
            ),
            title: Text(methodLabel),
            subtitle: Text('$date${days != null ? ' · $days일 전' : ''}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('이 기록을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteMemory(memory);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기록이 삭제되었습니다')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomHistory(
    BuildContext context,
    MemoryProvider provider,
    ThemeData theme,
  ) {
    final memories = provider.getMemoriesByType(MemoryType.custom);

    if (memories.isEmpty) {
      return Center(
        child: Text(
          '기록이 없습니다',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index] as CustomMemory;
        final date = DateFormat('yyyy년 M월 d일 HH:mm').format(memory.createdAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.note,
              color: theme.colorScheme.primary,
            ),
            title: Text(memory.name),
            subtitle: Text('$date${memory.payload['value'] != null ? ' · ${memory.payload['value']}' : ''}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CustomMemoryScreen(existingMemory: memory),
                    ),
                  );
                  if (context.mounted) {
                    provider.loadMemories();
                  }
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: const Text('이 기록을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteMemory(memory);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기록이 삭제되었습니다')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}

