class Student {
  final String id;
  final String name;
  final String className;
  final String parentName;
  final String parentPhone;
  final String? avatarUrl;
  final double? latitude;
  final double? longitude;
  final String status; // 'on_board', 'at_home', 'arrived'

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.parentName,
    required this.parentPhone,
    this.avatarUrl,
    this.latitude,
    this.longitude,
    this.status = 'at_home',
  });

  Student copyWith({
    String? id,
    String? name,
    String? className,
    String? parentName,
    String? parentPhone,
    String? avatarUrl,
    double? latitude,
    double? longitude,
    String? status,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
    );
  }
}

class Bus {
  final String id;
  final String plateNumber;
  final String driverName;
  final String driverPhone;
  final int capacity;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  Bus({
    required this.id,
    required this.plateNumber,
    required this.driverName,
    required this.driverPhone,
    required this.capacity,
    this.latitude,
    this.longitude,
    this.isActive = false,
  });
}

class Trip {
  final String id;
  final String busId;
  final String type; // 'morning', 'afternoon'
  final DateTime date;
  final String status; // 'scheduled', 'in_progress', 'completed'
  final List<String> studentIds;

  Trip({
    required this.id,
    required this.busId,
    required this.type,
    required this.date,
    required this.status,
    required this.studentIds,
  });
}

class Supervisor {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
  final List<String> assignedBusIds;

  Supervisor({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.assignedBusIds,
  });
}

class Parent {
  final String id;
  final String name;
  final String phone;
  final String email;
  final List<String> studentIds;

  Parent({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.studentIds,
  });
}

class NotificationSettings {
  final bool chat;
  final bool busNear;
  final bool busHere;
  final bool endTrip;
  final bool startTrip;
  final bool onBoard;
  final bool arrive;

  NotificationSettings({
    this.chat = false,
    this.busNear = false,
    this.busHere = false,
    this.endTrip = true,
    this.startTrip = true,
    this.onBoard = false,
    this.arrive = false,
  });

  NotificationSettings copyWith({
    bool? chat,
    bool? busNear,
    bool? busHere,
    bool? endTrip,
    bool? startTrip,
    bool? onBoard,
    bool? arrive,
  }) {
    return NotificationSettings(
      chat: chat ?? this.chat,
      busNear: busNear ?? this.busNear,
      busHere: busHere ?? this.busHere,
      endTrip: endTrip ?? this.endTrip,
      startTrip: startTrip ?? this.startTrip,
      onBoard: onBoard ?? this.onBoard,
      arrive: arrive ?? this.arrive,
    );
  }
}
