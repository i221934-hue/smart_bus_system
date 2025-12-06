import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// Mock data providers
final studentsProvider = StateProvider<List<Student>>((ref) => [
      Student(
        id: '1',
        name: 'Mohammed',
        className: 'ثامن / أ',
        parentName: 'Ahmed Al-Ali',
        parentPhone: '+968 9123 4567',
        latitude: 23.6100,
        longitude: 58.5400,
        status: 'at_home',
      ),
      Student(
        id: '2',
        name: 'Fatima',
        className: 'سابع / ب',
        parentName: 'Hassan Al-Balushi',
        parentPhone: '+968 9234 5678',
        latitude: 23.6150,
        longitude: 58.5450,
        status: 'on_board',
      ),
      Student(
        id: '3',
        name: 'Omar',
        className: 'تاسع / أ',
        parentName: 'Khalid Al-Harthy',
        parentPhone: '+968 9345 6789',
        latitude: 23.6200,
        longitude: 58.5500,
        status: 'arrived',
      ),
      Student(
        id: '4',
        name: 'Aisha',
        className: 'سادس / ج',
        parentName: 'Saeed Al-Lawati',
        parentPhone: '+968 9456 7890',
        latitude: 23.6050,
        longitude: 58.5350,
        status: 'at_home',
      ),
    ]);

final busesProvider = StateProvider<List<Bus>>((ref) => [
      Bus(
        id: '1',
        plateNumber: 'AB 1234',
        driverName: 'Ali Hassan',
        driverPhone: '+968 9111 2222',
        capacity: 40,
        latitude: 23.6100,
        longitude: 58.5400,
        isActive: true,
      ),
      Bus(
        id: '2',
        plateNumber: 'CD 5678',
        driverName: 'Yusuf Ahmed',
        driverPhone: '+968 9222 3333',
        capacity: 35,
        latitude: 23.6200,
        longitude: 58.5500,
        isActive: false,
      ),
      Bus(
        id: '3',
        plateNumber: 'EF 9012',
        driverName: 'Mahmoud Ibrahim',
        driverPhone: '+968 9333 4444',
        capacity: 45,
        isActive: false,
      ),
    ]);

final tripsProvider = StateProvider<List<Trip>>((ref) => [
      Trip(
        id: '1',
        busId: '1',
        type: 'morning',
        date: DateTime.now(),
        status: 'in_progress',
        studentIds: ['1', '2'],
      ),
      Trip(
        id: '2',
        busId: '2',
        type: 'afternoon',
        date: DateTime.now(),
        status: 'scheduled',
        studentIds: ['3', '4'],
      ),
    ]);

final supervisorsProvider = StateProvider<List<Supervisor>>((ref) => [
      Supervisor(
        id: '1',
        name: 'Sara Al-Farsi',
        phone: '+968 9555 6666',
        assignedBusIds: ['1'],
      ),
      Supervisor(
        id: '2',
        name: 'Noor Al-Kindi',
        phone: '+968 9666 7777',
        assignedBusIds: ['2', '3'],
      ),
    ]);

final parentsProvider = StateProvider<List<Parent>>((ref) => [
      Parent(
        id: '1',
        name: 'Ahmed Al-Ali',
        phone: '+968 9123 4567',
        email: 'ahmed@email.com',
        studentIds: ['1'],
      ),
      Parent(
        id: '2',
        name: 'Hassan Al-Balushi',
        phone: '+968 9234 5678',
        email: 'hassan@email.com',
        studentIds: ['2'],
      ),
    ]);

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings());

  void toggleChat(bool value) => state = state.copyWith(chat: value);
  void toggleBusNear(bool value) => state = state.copyWith(busNear: value);
  void toggleBusHere(bool value) => state = state.copyWith(busHere: value);
  void toggleEndTrip(bool value) => state = state.copyWith(endTrip: value);
  void toggleStartTrip(bool value) => state = state.copyWith(startTrip: value);
  void toggleOnBoard(bool value) => state = state.copyWith(onBoard: value);
  void toggleArrive(bool value) => state = state.copyWith(arrive: value);
}

// Navigation index provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// Selected student for tracking
final selectedStudentProvider = StateProvider<Student?>((ref) => null);

// User role provider
final userRoleProvider = StateProvider<String>(
    (ref) => 'principal'); // 'principal', 'parent', 'driver'
