import 'package:uuid/uuid.dart';

enum MemoryType {
  parking,
  beauty,
  razor,
  carWash,
  custom,
}

abstract class Memory {
  final String id;
  final MemoryType type;
  final DateTime createdAt;

  Memory({
    String? id,
    required this.type,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson();
}

class ParkingMemory extends Memory {
  final String place; // 'home' | 'office' | 'other'
  final String floor; // 'B3' ~ '10F'
  final String zone; // 'A'~'Z' | '1'~'20'

  ParkingMemory({
    super.id,
    required this.place,
    required this.floor,
    required this.zone,
    super.createdAt,
  }) : super(type: MemoryType.parking);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'parking',
        'place': place,
        'floor': floor,
        'zone': zone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ParkingMemory.fromJson(Map<String, dynamic> json) {
    return ParkingMemory(
      id: json['id'],
      place: json['place'],
      floor: json['floor'],
      zone: json['zone'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class BeautyMemory extends Memory {
  final String service; // 'cut' | 'perm' | 'color'
  final Map<String, dynamic> options;

  BeautyMemory({
    super.id,
    required this.service,
    this.options = const {},
    super.createdAt,
  }) : super(type: MemoryType.beauty);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'beauty',
        'service': service,
        'options': options,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BeautyMemory.fromJson(Map<String, dynamic> json) {
    return BeautyMemory(
      id: json['id'],
      service: json['service'],
      options: Map<String, dynamic>.from(json['options'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class RazorMemory extends Memory {
  final DateTime lastChangedAt;
  final String cycle; // 'monthly'
  final int notifyDay; // 1

  RazorMemory({
    super.id,
    required this.lastChangedAt,
    this.cycle = 'monthly',
    this.notifyDay = 1,
    super.createdAt,
  }) : super(type: MemoryType.razor);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'razor',
        'lastChangedAt': lastChangedAt.toIso8601String(),
        'cycle': cycle,
        'notifyDay': notifyDay,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RazorMemory.fromJson(Map<String, dynamic> json) {
    return RazorMemory(
      id: json['id'],
      lastChangedAt: DateTime.parse(json['lastChangedAt']),
      cycle: json['cycle'] ?? 'monthly',
      notifyDay: json['notifyDay'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CarWashMemory extends Memory {
  final String? method; // 'hand' | 'automatic' | 'self'

  CarWashMemory({
    super.id,
    this.method,
    super.createdAt,
  }) : super(type: MemoryType.carWash);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'car_wash',
        'method': method,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CarWashMemory.fromJson(Map<String, dynamic> json) {
    return CarWashMemory(
      id: json['id'],
      method: json['method'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CustomMemory extends Memory {
  final String name;
  final Map<String, dynamic> payload;

  CustomMemory({
    super.id,
    required this.name,
    this.payload = const {},
    super.createdAt,
  }) : super(type: MemoryType.custom);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'custom',
        'name': name,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomMemory.fromJson(Map<String, dynamic> json) {
    return CustomMemory(
      id: json['id'],
      name: json['name'],
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Factory for creating Memory from JSON
Memory memoryFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String;
  switch (type) {
    case 'parking':
      return ParkingMemory.fromJson(json);
    case 'beauty':
      return BeautyMemory.fromJson(json);
    case 'razor':
      return RazorMemory.fromJson(json);
    case 'car_wash':
      return CarWashMemory.fromJson(json);
    case 'custom':
      return CustomMemory.fromJson(json);
    default:
      throw Exception('Unknown memory type: $type');
  }
}

