import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_service.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });
}

/// GPS Location service with proper permission handling
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  final _locationController = StreamController<LocationData>.broadcast();
  bool _isTracking = false;
  LocationData? _lastLocation;
  String? _currentBusId;
  final _firebaseService = FirebaseService();

  Stream<LocationData> get locationStream => _locationController.stream;
  bool get isTracking => _isTracking;
  LocationData? get lastLocation => _lastLocation;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions with proper error handling
  /// Returns: 'granted', 'denied', 'deniedForever', 'serviceDisabled'
  Future<String> requestPermissions() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'serviceDisabled';
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return 'denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'deniedForever';
    }

    // Permission granted (always or whileInUse)
    return 'granted';
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings for permissions
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Get current position once with permission check
  Future<LocationData?> getCurrentLocation({
    required BuildContext context,
    bool showDialogs = true,
  }) async {
    try {
      final permissionResult = await requestPermissions();

      if (permissionResult != 'granted') {
        if (showDialogs && context.mounted) {
          _showPermissionDialog(context, permissionResult);
        }
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: DateTime.now(),
      );

      _lastLocation = locationData;
      return locationData;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Start continuous GPS tracking
  Future<bool> startTracking({
    required BuildContext context,
    String? busId,
    bool uploadToFirebase = true,
  }) async {
    if (_isTracking) return true;

    try {
      final permissionResult = await requestPermissions();

      if (permissionResult != 'granted') {
        if (context.mounted) {
          _showPermissionDialog(context, permissionResult);
        }
        return false;
      }

      _isTracking = true;
      _currentBusId = busId;

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          final locationData = LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            speed: position.speed,
            heading: position.heading,
            timestamp: DateTime.now(),
          );

          _lastLocation = locationData;
          _locationController.add(locationData);

          // Upload to Firebase if enabled
          if (uploadToFirebase &&
              _currentBusId != null &&
              _firebaseService.isInitialized) {
            _firebaseService.updateBusLocation(
              _currentBusId!,
              position.latitude,
              position.longitude,
              position.speed,
            );
          }
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error starting tracking: $e');
      _isTracking = false;
      return false;
    }
  }

  /// Stop GPS tracking
  Future<void> stopTracking() async {
    _isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    // Mark bus as inactive in Firebase
    if (_currentBusId != null && _firebaseService.isInitialized) {
      try {
        await _firebaseService.db
            .collection('buses')
            .doc(_currentBusId)
            .update({
          'isActive': false,
        });
      } catch (e) {
        debugPrint('Error updating bus status: $e');
      }
    }
    _currentBusId = null;
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Show permission dialog based on result
  void _showPermissionDialog(BuildContext context, String result) {
    String title;
    String message;
    VoidCallback? action;
    String actionText;

    switch (result) {
      case 'serviceDisabled':
        title = 'Location Services Disabled';
        message = 'Please enable location services to use GPS tracking.';
        actionText = 'Open Settings';
        action = () {
          Geolocator.openLocationSettings();
          Navigator.pop(context);
        };
        break;
      case 'denied':
        title = 'Location Permission Required';
        message =
            'This app needs location access to track the bus. Please grant permission.';
        actionText = 'Grant Permission';
        action = () {
          Navigator.pop(context);
          requestPermissions();
        };
        break;
      case 'deniedForever':
        title = 'Permission Permanently Denied';
        message =
            'Location permission was permanently denied. Please enable it from app settings.';
        actionText = 'Open App Settings';
        action = () {
          openAppSettings();
          Navigator.pop(context);
        };
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: action,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
