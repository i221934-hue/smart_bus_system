import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/models.dart';

/// Firebase service for cloud database operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initialize Firebase
  Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _initialized = true;
      return true;
    } catch (e) {
      print('Firebase initialization error: $e');
      _initialized = false;
      return false;
    }
  }

  FirebaseFirestore get db {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  // ==================== STUDENTS ====================

  CollectionReference<Map<String, dynamic>> get _studentsRef =>
      db.collection('students');

  Future<List<Student>> getStudents() async {
    if (!_initialized) return [];
    try {
      final snapshot = await _studentsRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Student(
          id: doc.id,
          name: data['name'] ?? '',
          className: data['className'] ?? '',
          parentName: data['parentName'] ?? '',
          parentPhone: data['parentPhone'] ?? '',
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
          status: data['status'] ?? 'at_home',
        );
      }).toList();
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }

  Future<void> saveStudent(Student student) async {
    if (!_initialized) return;
    try {
      await _studentsRef.doc(student.id).set({
        'name': student.name,
        'className': student.className,
        'parentName': student.parentName,
        'parentPhone': student.parentPhone,
        'latitude': student.latitude,
        'longitude': student.longitude,
        'status': student.status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving student: $e');
    }
  }

  Future<void> deleteStudent(String id) async {
    if (!_initialized) return;
    try {
      await _studentsRef.doc(id).delete();
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  Stream<List<Student>> studentsStream() {
    if (!_initialized) return Stream.value([]);
    return _studentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Student(
          id: doc.id,
          name: data['name'] ?? '',
          className: data['className'] ?? '',
          parentName: data['parentName'] ?? '',
          parentPhone: data['parentPhone'] ?? '',
          status: data['status'] ?? 'at_home',
        );
      }).toList();
    });
  }

  // ==================== BUSES ====================

  CollectionReference<Map<String, dynamic>> get _busesRef =>
      db.collection('buses');

  Future<List<Bus>> getBuses() async {
    if (!_initialized) return [];
    try {
      final snapshot = await _busesRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Bus(
          id: doc.id,
          plateNumber: data['plateNumber'] ?? '',
          driverName: data['driverName'] ?? '',
          driverPhone: data['driverPhone'] ?? '',
          capacity: data['capacity'] ?? 40,
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
          isActive: data['isActive'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Error getting buses: $e');
      return [];
    }
  }

  Future<void> saveBus(Bus bus) async {
    if (!_initialized) return;
    try {
      await _busesRef.doc(bus.id).set({
        'plateNumber': bus.plateNumber,
        'driverName': bus.driverName,
        'driverPhone': bus.driverPhone,
        'capacity': bus.capacity,
        'latitude': bus.latitude,
        'longitude': bus.longitude,
        'isActive': bus.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving bus: $e');
    }
  }

  Future<void> deleteBus(String id) async {
    if (!_initialized) return;
    try {
      await _busesRef.doc(id).delete();
    } catch (e) {
      print('Error deleting bus: $e');
    }
  }

  /// Update bus location in real-time (called by driver)
  Future<void> updateBusLocation(
      String busId, double lat, double lng, double speed) async {
    if (!_initialized) return;
    try {
      await _busesRef.doc(busId).update({
        'latitude': lat,
        'longitude': lng,
        'speed': speed,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      print('Error updating bus location: $e');
    }
  }

  /// Stream bus location for parents to track
  Stream<Map<String, dynamic>?> busLocationStream(String busId) {
    if (!_initialized) return Stream.value(null);
    return _busesRef.doc(busId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      return {
        'latitude': data?['latitude'] ?? 0,
        'longitude': data?['longitude'] ?? 0,
        'speed': data?['speed'] ?? 0,
        'isActive': data?['isActive'] ?? false,
      };
    });
  }

  // ==================== TRIPS ====================

  CollectionReference<Map<String, dynamic>> get _tripsRef =>
      db.collection('trips');

  Future<List<Trip>> getTrips() async {
    if (!_initialized) return [];
    try {
      final snapshot =
          await _tripsRef.orderBy('date', descending: true).limit(20).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Trip(
          id: doc.id,
          busId: data['busId'] ?? '',
          type: data['type'] ?? 'morning',
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: data['status'] ?? 'scheduled',
          studentIds: List<String>.from(data['studentIds'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('Error getting trips: $e');
      return [];
    }
  }

  Future<void> saveTrip(Trip trip) async {
    if (!_initialized) return;
    try {
      await _tripsRef.doc(trip.id).set({
        'busId': trip.busId,
        'type': trip.type,
        'date': Timestamp.fromDate(trip.date),
        'status': trip.status,
        'studentIds': trip.studentIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving trip: $e');
    }
  }

  // ==================== SCHOOL INFO ====================

  DocumentReference<Map<String, dynamic>> get _schoolRef =>
      db.collection('settings').doc('school');

  Future<Map<String, dynamic>?> getSchoolInfo() async {
    if (!_initialized) return null;
    try {
      final doc = await _schoolRef.get();
      return doc.data();
    } catch (e) {
      print('Error getting school info: $e');
      return null;
    }
  }

  Future<void> saveSchoolInfo(Map<String, dynamic> info) async {
    if (!_initialized) return;
    try {
      await _schoolRef.set(info);
    } catch (e) {
      print('Error saving school info: $e');
    }
  }

  // ==================== STATISTICS ====================

  Future<Map<String, int>> getStatistics() async {
    if (!_initialized) {
      return {'students': 0, 'buses': 0, 'trips': 0, 'supervisors': 0};
    }
    try {
      final students = await _studentsRef.count().get();
      final buses = await _busesRef.count().get();
      final trips = await _tripsRef.count().get();
      final supervisors = await db.collection('supervisors').count().get();

      return {
        'students': students.count ?? 0,
        'buses': buses.count ?? 0,
        'trips': trips.count ?? 0,
        'supervisors': supervisors.count ?? 0,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {'students': 0, 'buses': 0, 'trips': 0, 'supervisors': 0};
    }
  }
}
