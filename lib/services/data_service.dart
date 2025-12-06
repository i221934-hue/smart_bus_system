import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class DataService {
  static const String _studentsKey = 'students_data';
  static const String _busesKey = 'buses_data';
  static const String _tripsKey = 'trips_data';
  static const String _supervisorsKey = 'supervisors_data';
  static const String _notificationSettingsKey = 'notification_settings';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ============ STUDENTS ============

  Future<List<Student>> getStudents() async {
    final prefs = await _prefs;
    final data = prefs.getStringList(_studentsKey) ?? [];
    return data.map((s) => _studentFromJson(jsonDecode(s))).toList();
  }

  Future<void> saveStudent(Student student) async {
    final prefs = await _prefs;
    final students = await getStudents();

    final index = students.indexWhere((s) => s.id == student.id);
    if (index >= 0) {
      students[index] = student;
    } else {
      students.add(student);
    }

    await prefs.setStringList(
      _studentsKey,
      students.map((s) => jsonEncode(_studentToJson(s))).toList(),
    );
  }

  Future<void> deleteStudent(String id) async {
    final prefs = await _prefs;
    final students = await getStudents();
    students.removeWhere((s) => s.id == id);
    await prefs.setStringList(
      _studentsKey,
      students.map((s) => jsonEncode(_studentToJson(s))).toList(),
    );
  }

  Student _studentFromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        name: json['name'],
        className: json['className'],
        parentName: json['parentName'],
        parentPhone: json['parentPhone'],
        avatarUrl: json['avatarUrl'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        status: json['status'] ?? 'at_home',
      );

  Map<String, dynamic> _studentToJson(Student s) => {
        'id': s.id,
        'name': s.name,
        'className': s.className,
        'parentName': s.parentName,
        'parentPhone': s.parentPhone,
        'avatarUrl': s.avatarUrl,
        'latitude': s.latitude,
        'longitude': s.longitude,
        'status': s.status,
      };

  // ============ BUSES ============

  Future<List<Bus>> getBuses() async {
    final prefs = await _prefs;
    final data = prefs.getStringList(_busesKey) ?? [];
    return data.map((b) => _busFromJson(jsonDecode(b))).toList();
  }

  Future<void> saveBus(Bus bus) async {
    final prefs = await _prefs;
    final buses = await getBuses();

    final index = buses.indexWhere((b) => b.id == bus.id);
    if (index >= 0) {
      buses[index] = bus;
    } else {
      buses.add(bus);
    }

    await prefs.setStringList(
      _busesKey,
      buses.map((b) => jsonEncode(_busToJson(b))).toList(),
    );
  }

  Future<void> deleteBus(String id) async {
    final prefs = await _prefs;
    final buses = await getBuses();
    buses.removeWhere((b) => b.id == id);
    await prefs.setStringList(
      _busesKey,
      buses.map((b) => jsonEncode(_busToJson(b))).toList(),
    );
  }

  Bus _busFromJson(Map<String, dynamic> json) => Bus(
        id: json['id'],
        plateNumber: json['plateNumber'],
        driverName: json['driverName'],
        driverPhone: json['driverPhone'],
        capacity: json['capacity'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        isActive: json['isActive'] ?? false,
      );

  Map<String, dynamic> _busToJson(Bus b) => {
        'id': b.id,
        'plateNumber': b.plateNumber,
        'driverName': b.driverName,
        'driverPhone': b.driverPhone,
        'capacity': b.capacity,
        'latitude': b.latitude,
        'longitude': b.longitude,
        'isActive': b.isActive,
      };

  // ============ TRIPS ============

  Future<List<Trip>> getTrips() async {
    final prefs = await _prefs;
    final data = prefs.getStringList(_tripsKey) ?? [];
    return data.map((t) => _tripFromJson(jsonDecode(t))).toList();
  }

  Future<void> saveTrip(Trip trip) async {
    final prefs = await _prefs;
    final trips = await getTrips();

    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      trips[index] = trip;
    } else {
      trips.add(trip);
    }

    await prefs.setStringList(
      _tripsKey,
      trips.map((t) => jsonEncode(_tripToJson(t))).toList(),
    );
  }

  Trip _tripFromJson(Map<String, dynamic> json) => Trip(
        id: json['id'],
        busId: json['busId'],
        type: json['type'],
        date: DateTime.parse(json['date']),
        status: json['status'],
        studentIds: List<String>.from(json['studentIds']),
      );

  Map<String, dynamic> _tripToJson(Trip t) => {
        'id': t.id,
        'busId': t.busId,
        'type': t.type,
        'date': t.date.toIso8601String(),
        'status': t.status,
        'studentIds': t.studentIds,
      };

  // ============ SUPERVISORS ============

  Future<List<Supervisor>> getSupervisors() async {
    final prefs = await _prefs;
    final data = prefs.getStringList(_supervisorsKey) ?? [];
    return data.map((s) => _supervisorFromJson(jsonDecode(s))).toList();
  }

  Future<void> saveSupervisor(Supervisor supervisor) async {
    final prefs = await _prefs;
    final supervisors = await getSupervisors();

    final index = supervisors.indexWhere((s) => s.id == supervisor.id);
    if (index >= 0) {
      supervisors[index] = supervisor;
    } else {
      supervisors.add(supervisor);
    }

    await prefs.setStringList(
      _supervisorsKey,
      supervisors.map((s) => jsonEncode(_supervisorToJson(s))).toList(),
    );
  }

  Supervisor _supervisorFromJson(Map<String, dynamic> json) => Supervisor(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        avatarUrl: json['avatarUrl'],
        assignedBusIds: List<String>.from(json['assignedBusIds']),
      );

  Map<String, dynamic> _supervisorToJson(Supervisor s) => {
        'id': s.id,
        'name': s.name,
        'phone': s.phone,
        'avatarUrl': s.avatarUrl,
        'assignedBusIds': s.assignedBusIds,
      };

  // ============ NOTIFICATION SETTINGS ============

  Future<NotificationSettings> getNotificationSettings() async {
    final prefs = await _prefs;
    final data = prefs.getString(_notificationSettingsKey);
    if (data == null) return NotificationSettings();

    final json = jsonDecode(data);
    return NotificationSettings(
      chat: json['chat'] ?? false,
      busNear: json['busNear'] ?? false,
      busHere: json['busHere'] ?? false,
      endTrip: json['endTrip'] ?? true,
      startTrip: json['startTrip'] ?? true,
      onBoard: json['onBoard'] ?? false,
      arrive: json['arrive'] ?? false,
    );
  }

  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final prefs = await _prefs;
    await prefs.setString(
        _notificationSettingsKey,
        jsonEncode({
          'chat': settings.chat,
          'busNear': settings.busNear,
          'busHere': settings.busHere,
          'endTrip': settings.endTrip,
          'startTrip': settings.startTrip,
          'onBoard': settings.onBoard,
          'arrive': settings.arrive,
        }));
  }

  // ============ INITIAL DATA SETUP ============

  Future<void> initializeDefaultData() async {
    final students = await getStudents();
    final buses = await getBuses();

    // Only initialize if no data exists
    if (students.isEmpty && buses.isEmpty) {
      // This will be empty - users need to add their own data
      // No mock data will be created
    }
  }
}
