import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/localization_service.dart';
import '../models/models.dart';
import '../main.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();
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
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();

    final screens = [
      _ParentDashboard(
          user: _currentUser, firebaseService: _firebaseService, loc: loc),
      _TrackBusScreen(firebaseService: _firebaseService, loc: loc),
      _NotificationsScreen(loc: loc),
      _ParentSettingsScreen(onLogout: _logout, loc: loc),
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
                icon: const Icon(Icons.home), label: loc.home),
            BottomNavigationBarItem(
                icon: const Icon(Icons.map), label: loc.trackBus),
            BottomNavigationBarItem(
                icon: const Icon(Icons.notifications),
                label: loc.notifications),
            BottomNavigationBarItem(
                icon: const Icon(Icons.settings), label: loc.settings),
          ],
        ),
      ),
    );
  }
}

class _ParentDashboard extends StatefulWidget {
  final User? user;
  final FirebaseService firebaseService;
  final AppLocalizations loc;

  const _ParentDashboard(
      {this.user, required this.firebaseService, required this.loc});

  @override
  State<_ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<_ParentDashboard> {
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
    // Filter to show only linked students (for now, show first 2)
    setState(() {
      _students = students;
      _isLoading = false;
    });
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
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            color: AppTheme.primaryBlue, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.loc.isArabic ? 'مرحباً' : 'Welcome',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.white70),
                            ),
                            Text(
                              widget.user?.name ?? widget.loc.parent,
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
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
                child: RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        widget.loc.myChildren,
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_students.isEmpty)
                        _EmptyState(
                          icon: Icons.child_care,
                          title: widget.loc.noStudentsLinked,
                          subtitle: widget.loc.contactAdmin,
                        )
                      else
                        ..._students.map((student) => _StudentInfoCard(
                            student: student, loc: widget.loc)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  final Student student;
  final AppLocalizations loc;

  const _StudentInfoCard({required this.student, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryBlue.withAlpha(25),
            child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text('${loc.className}: ${student.className}',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(student.status).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(student.status),
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(student.status)),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        return loc.onBoard;
      case 'arrived':
        return loc.arrived;
      default:
        return loc.atHome;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 60, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Text(subtitle,
              style:
                  GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TrackBusScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final AppLocalizations loc;

  const _TrackBusScreen({required this.firebaseService, required this.loc});

  @override
  State<_TrackBusScreen> createState() => _TrackBusScreenState();
}

class _TrackBusScreenState extends State<_TrackBusScreen> {
  final _locationService = LocationService();
  final _mapController = MapController();
  LocationData? _myLocation;
  LatLng? _busLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocations();
  }

  Future<void> _initLocations() async {
    // Get user's location
    final myLoc = await _locationService.getCurrentLocation(
        context: context, showDialogs: false);

    // Get bus location from Firebase (listen to first active bus)
    final buses = await widget.firebaseService.getBuses();
    final activeBus = buses.where((b) => b.isActive).firstOrNull;

    setState(() {
      _myLocation = myLoc;
      if (activeBus != null && activeBus.latitude != 0) {
        _busLocation =
            LatLng(activeBus.latitude ?? 23.61, activeBus.longitude ?? 58.54);
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = _busLocation ??
        (_myLocation != null
            ? LatLng(_myLocation!.latitude, _myLocation!.longitude)
            : const LatLng(23.6100, 58.5400));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loc.trackBus),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
        actions: [
          if (_busLocation != null)
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: center, initialZoom: 14),
                  children: [
                    TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.masar.masar_smart_bus'),
                    MarkerLayer(
                      markers: [
                        // My location
                        if (_myLocation != null)
                          Marker(
                            point: LatLng(
                                _myLocation!.latitude, _myLocation!.longitude),
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 8)
                                ],
                              ),
                              child: const Icon(Icons.home,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                        // Bus location
                        if (_busLocation != null)
                          Marker(
                            point: _busLocation!,
                            width: 60,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.accentYellow,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(75),
                                      blurRadius: 10)
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
                // Info card at bottom
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(25), blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentYellow.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.directions_bus,
                              color: AppTheme.accentYellow, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _busLocation != null
                                    ? widget.loc.isArabic
                                        ? 'الحافلة في الطريق'
                                        : 'Bus is on the way'
                                    : widget.loc.isArabic
                                        ? 'لا يوجد حافلة نشطة'
                                        : 'No active bus',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              if (_busLocation != null)
                                Text(
                                  '${widget.loc.estimatedArrival}: 5-10 ${widget.loc.minutes}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: AppTheme.textMuted),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final loc =
              await _locationService.getCurrentLocation(context: context);
          if (loc != null) {
            setState(() => _myLocation = loc);
            _mapController.move(LatLng(loc.latitude, loc.longitude), 15);
          }
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

class _NotificationsScreen extends StatelessWidget {
  final AppLocalizations loc;

  const _NotificationsScreen({required this.loc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.notifications),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
        actions: const [LanguageToggleButton()],
      ),
      body: Center(
        child: _EmptyState(
          icon: Icons.notifications_off_outlined,
          title: loc.notifications,
          subtitle: loc.isArabic
              ? 'لا توجد إشعارات جديدة'
              : 'No new notifications right now',
        ),
      ),
    );
  }
}

class _ParentSettingsScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final AppLocalizations loc;

  const _ParentSettingsScreen({required this.onLogout, required this.loc});

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
              onTap: onLogout),
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
