import 'package:flutter/foundation.dart';
import '../models/memory.dart';
import '../services/memory_storage.dart';
import '../utils/reminder_helper.dart';

class MemoryProvider with ChangeNotifier {
  final MemoryStorage _storage = MemoryStorage();

  Map<MemoryType, List<Memory>> _memories = {
    MemoryType.parking: [],
    MemoryType.beauty: [],
    MemoryType.razor: [],
    MemoryType.carWash: [],
    MemoryType.custom: [],
  };

  bool _isLoading = false;
  bool _reminderDismissed = false;

  Map<MemoryType, List<Memory>> get memories => _memories;
  bool get isLoading => _isLoading;
  bool get reminderDismissed => _reminderDismissed;

  // Get latest memory by type
  Memory? getLatestMemory(MemoryType type) {
    final list = _memories[type]!;
    if (list.isEmpty) return null;
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.first;
  }

  // Get all memories by type
  List<Memory> getMemoriesByType(MemoryType type) {
    final list = _memories[type]!;
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // Check if razor reminder should be shown
  bool shouldShowRazorReminder() {
    if (_reminderDismissed) return false;
    final razor = getLatestMemory(MemoryType.razor);
    if (razor is RazorMemory) {
      return ReminderHelper.shouldShowRazorReminder(razor);
    }
    return false;
  }

  // Dismiss reminder
  void dismissReminder() {
    _reminderDismissed = true;
    notifyListeners();
  }

  // Load memories from storage
  Future<void> loadMemories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _memories = await _storage.loadMemories();
      _reminderDismissed = false; // Reset on load
    } catch (e) {
      debugPrint('Error loading memories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add memory
  Future<void> addMemory(Memory memory) async {
    _memories[memory.type]!.add(memory);
    await _storage.saveMemories(_memories);
    notifyListeners();
  }

  // Initialize (load on app start)
  Future<void> initialize() async {
    await loadMemories();
  }
}

