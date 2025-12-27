import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../widgets/memory_card.dart';
import '../widgets/reminder_banner.dart';
import 'parking_screen.dart';
import 'beauty_screen.dart';
import 'razor_screen.dart';
import 'car_wash_screen.dart';
import 'custom_memory_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemoryProvider>(context, listen: false).loadMemories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MemoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
            tooltip: '히스토리',
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadMemories(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Reminder banner
                    if (provider.shouldShowRazorReminder())
                      ReminderBanner(
                        razorMemory: provider.getLatestMemory(MemoryType.razor) as RazorMemory?,
                        onDismiss: () => provider.dismissReminder(),
                      ),

                    // Memory cards
                    MemoryCard(
                      memory: provider.getLatestMemory(MemoryType.parking),
                      type: MemoryType.parking,
                      title: '주차 위치',
                      icon: Icons.local_parking,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ParkingScreen(),
                          ),
                        );
                        if (mounted) {
                          provider.loadMemories();
                        }
                      },
                    ),

                    MemoryCard(
                      memory: provider.getLatestMemory(MemoryType.beauty),
                      type: MemoryType.beauty,
                      title: '미용실',
                      icon: Icons.content_cut,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const BeautyScreen(),
                          ),
                        );
                        if (mounted) {
                          provider.loadMemories();
                        }
                      },
                    ),

                    MemoryCard(
                      memory: provider.getLatestMemory(MemoryType.razor),
                      type: MemoryType.razor,
                      title: '면도날 교체',
                      icon: Icons.refresh,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RazorScreen(),
                          ),
                        );
                        if (mounted) {
                          provider.loadMemories();
                        }
                      },
                    ),

                    MemoryCard(
                      memory: provider.getLatestMemory(MemoryType.carWash),
                      type: MemoryType.carWash,
                      title: '세차',
                      icon: Icons.local_car_wash,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CarWashScreen(),
                          ),
                        );
                        if (mounted) {
                          provider.loadMemories();
                        }
                      },
                    ),

                    MemoryCard(
                      memory: provider.getLatestMemory(MemoryType.custom),
                      type: MemoryType.custom,
                      title: '커스텀 메모리',
                      icon: Icons.note_add,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CustomMemoryScreen(),
                          ),
                        );
                        if (mounted) {
                          provider.loadMemories();
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}

