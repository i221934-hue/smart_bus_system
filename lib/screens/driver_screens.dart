import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/firebase_service.dart';
import '../services/localization_service.dart';
import '../models/models.dart';
import '../main.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();
  final _locationService = LocationService();
  User? _currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    AppLocalizations().addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppLocalizations().removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _logout() async {
    await _locationService.stopTracking();
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();

    final screens = [
      _DriverDashboard(
          user: _currentUser, locationService: _locationService, loc: loc),
      _DriverTripScreen(
          firebaseService: _firebaseService,
          locationService: _locationService,
          loc: loc),
      _DriverStudentsScreen(firebaseService: _firebaseService, loc: loc),
      _DriverSettingsScreen(onLogout: _logout, loc: loc),
    ];

    return LocalizedScreen(
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.textMuted,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard), label: loc.dashboard),
            BottomNavigationBarItem(
                icon: const Icon(Icons.directions),
                label: loc.isArabic ? 'الرحلة' : 'Trip'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.people), label: loc.students),
            BottomNavigationBarItem(
                icon: const Icon(Icons.settings), label: loc.settings),
          ],
        ),
      ),
    );
  }
}

class _DriverDashboard extends StatefulWidget {
  final User? user;
  final LocationService locationService;
  final AppLocalizations loc;

  const _DriverDashboard(
      {this.user, required this.locationService, required this.loc});

  @override
  State<_DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<_DriverDashboard> {
  bool _isTracking = false;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  int _studentsOnBoard = 0;
  String _tripStatus = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkTrackingStatus();
    _tripStatus = widget.loc.notStarted;
  }

  void _checkTrackingStatus() {
    _isTracking = widget.locationService.isTracking;
    _currentLocation = widget.locationService.lastLocation;
    if (_isTracking) {
      _tripStatus = widget.loc.inProgress;
    }
  }

  Future<void> _toggleTracking() async {
    setState(() => _isLoading = true);

    if (_isTracking) {
      await widget.locationService.stopTracking();
      _locationSubscription?.cancel();
      setState(() {
        _isTracking = false;
        _tripStatus = widget.loc.tripEnded;
        _isLoading = false;
      });
      _showSnackbar(widget.loc.trackingStopped, AppTheme.errorRed);
    } else {
      // Start tracking with permission check
      final success = await widget.locationService.startTracking(
        context: context,
        busId: 'bus_${widget.user?.id ?? 'default'}',
        uploadToFirebase: true,
      );

      if (success) {
        _locationSubscription =
            widget.locationService.locationStream.listen((location) {
          if (mounted) {
            setState(() => _currentLocation = location);
          }
        });
        setState(() {
          _isTracking = true;
          _tripStatus = widget.loc.inProgress;
        });
        _showSnackbar(widget.loc.trackingStarted, AppTheme.successGreen);
      }
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [AppTheme.primaryBlue, Color(0xFF3D5A80)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: widget.loc.isArabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: const LanguageToggleButton(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.directions_bus,
                            color: AppTheme.accentYellow, size: 35),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.loc.driverDashboard,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.white70),
                            ),
                            Text(
                              widget.user?.name ?? widget.loc.driver,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // GPS Status Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              _isTracking ? AppTheme.successGreen : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: _isTracking
                                    ? [
                                        BoxShadow(
                                            color: Colors.white.withAlpha(150),
                                            blurRadius: 4,
                                            spreadRadius: 2),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isTracking ? 'GPS' : 'OFF',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.loc.tripStatus,
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isTracking
                                      ? AppTheme.successGreen.withAlpha(25)
                                      : AppTheme.errorRed.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _tripStatus,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _isTracking
                                        ? AppTheme.successGreen
                                        : AppTheme.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_currentLocation != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withAlpha(10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: AppTheme.primaryBlue,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppTheme.textDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.transparent, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppTheme.textDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.speed,
                                          color: AppTheme.accentYellow,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${widget.loc.speed}: ${(_currentLocation!.speed * 3.6).toStringAsFixed(1)} km/h',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.gps_off,
                                      color: AppTheme.textMuted),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.loc.gpsInactive,
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _toggleTracking,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Icon(_isTracking
                                      ? Icons.stop
                                      : Icons.play_arrow),
                              label: Text(
                                _isTracking
                                    ? widget.loc.stopTrip
                                    : widget.loc.startTrip,
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isTracking
                                    ? AppTheme.errorRed
                                    : AppTheme.successGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people,
                            value: '$_studentsOnBoard',
                            label: widget.loc.onBoard,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            value: '0',
                            label: widget.loc.droppedOff,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label,
              style:
                  GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _DriverTripScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final LocationService locationService;
  final AppLocalizations loc;

  const _DriverTripScreen(
      {required this.firebaseService,
      required this.locationService,
      required this.loc});

  @override
  State<_DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<_DriverTripScreen> {
  final _mapController = MapController();
  StreamSubscription<LocationData>? _locationSubscription;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // Get current location
    final location = await widget.locationService
        .getCurrentLocation(context: context, showDialogs: false);
    if (location != null && mounted) {
      setState(() => _currentLocation = location);
    }

    // Listen to location stream
    _locationSubscription =
        widget.locationService.locationStream.listen((location) {
      if (mounted) {
        setState(() => _currentLocation = location);
        _mapController.move(LatLng(location.latitude, location.longitude),
            _mapController.camera.zoom);
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentLocation != null
        ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
        : const LatLng(23.6100, 58.5400);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loc.tripMap),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
        actions: [
          if (widget.locationService.isTracking)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.successGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('LIVE',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
          const LanguageToggleButton(),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: center, initialZoom: 15),
        children: [
          TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.masar.masar_smart_bus'),
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                      _currentLocation!.latitude, _currentLocation!.longitude),
                  width: 60,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(75), blurRadius: 10)
                      ],
                    ),
                    child: const Icon(Icons.directions_bus,
                        color: Colors.white, size: 35),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final location =
              await widget.locationService.getCurrentLocation(context: context);
          if (location != null) {
            _mapController.move(
                LatLng(location.latitude, location.longitude), 15);
          }
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

class _DriverStudentsScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final AppLocalizations loc;

  const _DriverStudentsScreen(
      {required this.firebaseService, required this.loc});

  @override
  State<_DriverStudentsScreen> createState() => _DriverStudentsScreenState();
}

class _DriverStudentsScreenState extends State<_DriverStudentsScreen> {
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final students = await widget.firebaseService.getStudents();
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  Future<void> _updateStudentStatus(Student student, String newStatus) async {
    final updated = student.copyWith(status: newStatus);
    await widget.firebaseService.saveStudent(updated);
    await _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loc.students),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStudents),
          const LanguageToggleButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 60, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text(widget.loc.noStudentsAssigned,
                          style:
                              GoogleFonts.poppins(color: AppTheme.textMuted)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppTheme.primaryBlue.withAlpha(25),
                              child: Icon(Icons.person,
                                  color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.name,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600)),
                                  Text(student.className,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (status) =>
                                  _updateStudentStatus(student, status),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                    value: 'at_home',
                                    child: Text(widget.loc.atHome)),
                                PopupMenuItem(
                                    value: 'on_board',
                                    child: Text(widget.loc.onBoard)),
                                PopupMenuItem(
                                    value: 'arrived',
                                    child: Text(widget.loc.arrived)),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(student.status)
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _getStatusText(student.status),
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _getStatusColor(student.status)),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down,
                                        color: _getStatusColor(student.status),
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'on_board':
        return AppTheme.successGreen;
      case 'arrived':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.accentYellow;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'on_board':
        return widget.loc.onBoard;
      case 'arrived':
        return widget.loc.arrived;
      default:
        return widget.loc.atHome;
    }
  }
}

class _DriverSettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final AppLocalizations loc;

  const _DriverSettingsScreen({required this.onLogout, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
        actions: const [LanguageToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
              icon: Icons.notifications,
              title: loc.notifications,
              onTap: () => Navigator.pushNamed(context, '/notifications')),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout,
            title: loc.logout,
            iconColor: AppTheme.errorRed,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.icon,
      required this.title,
      this.iconColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryBlue),
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
