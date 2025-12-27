import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';

class MemoryStorage {
  static const String _storageKey = 'memory_agent_data';

  // Load all memories
  Future<Map<MemoryType, List<Memory>>> loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return {
        MemoryType.parking: [],
        MemoryType.beauty: [],
        MemoryType.razor: [],
        MemoryType.carWash: [],
        MemoryType.custom: [],
      };
    }

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final memoriesData = data['memories'] as Map<String, dynamic>;

    return {
      MemoryType.parking: (memoriesData['parking'] as List<dynamic>?)
              ?.map((e) => memoryFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      MemoryType.beauty: (memoriesData['beauty'] as List<dynamic>?)
              ?.map((e) => memoryFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      MemoryType.razor: (memoriesData['razor'] as List<dynamic>?)
              ?.map((e) => memoryFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      MemoryType.carWash: (memoriesData['car_wash'] as List<dynamic>?)
              ?.map((e) => memoryFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      MemoryType.custom: (memoriesData['custom'] as List<dynamic>?)
              ?.map((e) => memoryFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    };
  }

  // Save all memories
  Future<void> saveMemories(Map<MemoryType, List<Memory>> memories) async {
    final prefs = await SharedPreferences.getInstance();

    final memoriesData = {
      'parking': memories[MemoryType.parking]!
          .map((m) => m.toJson())
          .toList(),
      'beauty': memories[MemoryType.beauty]!
          .map((m) => m.toJson())
          .toList(),
      'razor': memories[MemoryType.razor]!
          .map((m) => m.toJson())
          .toList(),
      'car_wash': memories[MemoryType.carWash]!
          .map((m) => m.toJson())
          .toList(),
      'custom': memories[MemoryType.custom]!
          .map((m) => m.toJson())
          .toList(),
    };

    final data = {
      'memories': memoriesData,
    };

    await prefs.setString(_storageKey, jsonEncode(data));
  }

  // Add a memory
  Future<void> addMemory(Memory memory) async {
    final memories = await loadMemories();
    memories[memory.type]!.add(memory);
    await saveMemories(memories);
  }

  // Get latest memory of a type
  Future<Memory?> getLatestMemory(MemoryType type) async {
    final memories = await loadMemories();
    final list = memories[type]!;
    if (list.isEmpty) return null;
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.first;
  }

  // Get all memories of a type
  Future<List<Memory>> getMemoriesByType(MemoryType type) async {
    final memories = await loadMemories();
    final list = memories[type]!;
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}

