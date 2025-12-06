import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/localization_service.dart';
import '../models/models.dart';
import '../main.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
      _ControlPanelScreen(
          firebaseService: _firebaseService, user: _currentUser, loc: loc),
      _ManageStudentsScreen(firebaseService: _firebaseService, loc: loc),
      _ManageBusesScreen(firebaseService: _firebaseService, loc: loc),
      _AdminSettingsScreen(
          onLogout: _logout, firebaseService: _firebaseService, loc: loc),
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
                icon: const Icon(Icons.dashboard), label: loc.controlPanel),
            BottomNavigationBarItem(
                icon: const Icon(Icons.people), label: loc.students),
            BottomNavigationBarItem(
                icon: const Icon(Icons.directions_bus), label: loc.buses),
            BottomNavigationBarItem(
                icon: const Icon(Icons.settings), label: loc.settings),
          ],
        ),
      ),
    );
  }
}

/// Control Panel - Admin Dashboard with Statistics (based on Smart Track design)
class _ControlPanelScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final User? user;
  final AppLocalizations loc;

  const _ControlPanelScreen(
      {required this.firebaseService, this.user, required this.loc});

  @override
  State<_ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<_ControlPanelScreen> {
  Map<String, int> _stats = {
    'students': 0,
    'buses': 0,
    'trips': 0,
    'supervisors': 0
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await widget.firebaseService.getStatistics();
    setState(() {
      _stats = stats;
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
            // Header
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
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) => Icon(Icons.school,
                              color: AppTheme.primaryBlue, size: 40),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart track',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.loc.isArabic
                                  ? 'مدرسة الإمام عبدالملك بن حميد'
                                  : 'Imam Abdulmalik bin Humaid School',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
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
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.loc.controlPanel,
                          style: GoogleFonts.poppins(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.loc.overviewStats,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Column(
                            children: [
                              _StatisticCard(
                                icon: Icons.groups,
                                title: widget.loc.totalStudents,
                                value: '${_stats['students']}',
                                subtitle: widget.loc.studentsRegistered,
                                // change: '+5%',
                                // changeText: widget.loc.fromLastMonth,
                                color: AppTheme.primaryBlue,
                              ),
                              _StatisticCard(
                                icon: Icons.supervisor_account,
                                title: widget.loc.supervisors,
                                value: '${_stats['supervisors']}',
                                subtitle: widget.loc.activeSupervisors,
                                color: AppTheme.secondaryGreen,
                              ),
                              _StatisticCard(
                                icon: Icons.directions_bus,
                                title: widget.loc.schoolBuses,
                                value: '${_stats['buses']}',
                                subtitle: widget.loc.busesInService,
                                color: AppTheme.accentYellow,
                              ),
                              _StatisticCard(
                                icon: Icons.add_circle_outline,
                                title: widget.loc.newEntry,
                                value: '${_stats['trips']}',
                                subtitle: widget.loc.thisWeek,
                                // change: '+12%',
                                // changeText: widget.loc.fromLastMonth,
                                color: AppTheme.successGreen,
                              ),
                            ],
                          ),
                      ],
                    ),
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

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.textMuted)),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark),
                ),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ManageStudentsScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final AppLocalizations loc;

  const _ManageStudentsScreen(
      {required this.firebaseService, required this.loc});

  @override
  State<_ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<_ManageStudentsScreen> {
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

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final classController = TextEditingController();
    final parentNameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.loc.addStudent),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: widget.loc.studentName)),
              TextField(
                  controller: classController,
                  decoration: InputDecoration(labelText: widget.loc.className)),
              TextField(
                  controller: parentNameController,
                  decoration:
                      InputDecoration(labelText: widget.loc.parentName)),
              TextField(
                  controller: phoneController,
                  decoration:
                      InputDecoration(labelText: widget.loc.parentPhone)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(widget.loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final student = Student(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  className: classController.text,
                  parentName: parentNameController.text,
                  parentPhone: phoneController.text,
                );
                await widget.firebaseService.saveStudent(student);
                Navigator.pop(context);
                _loadStudents();
              }
            },
            child: Text(widget.loc.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loc.manageStudents),
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
                      Text(widget.loc.noStudentsYet,
                          style:
                              GoogleFonts.poppins(color: AppTheme.textMuted)),
                      Text(widget.loc.tapToAdd,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppTheme.textMuted)),
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
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 8)
                          ],
                        ),
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
                                  Text(
                                      '${widget.loc.className}: ${student.className}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textMuted)),
                                  Text(student.parentPhone,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.primaryBlue)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () async {
                                await widget.firebaseService
                                    .deleteStudent(student.id);
                                _loadStudents();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ManageBusesScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final AppLocalizations loc;

  const _ManageBusesScreen({required this.firebaseService, required this.loc});

  @override
  State<_ManageBusesScreen> createState() => _ManageBusesScreenState();
}

class _ManageBusesScreenState extends State<_ManageBusesScreen> {
  List<Bus> _buses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    setState(() => _isLoading = true);
    final buses = await widget.firebaseService.getBuses();
    setState(() {
      _buses = buses;
      _isLoading = false;
    });
  }

  void _showAddBusDialog() {
    final plateController = TextEditingController();
    final driverController = TextEditingController();
    final phoneController = TextEditingController();
    final capacityController = TextEditingController(text: '40');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.loc.addBus),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: plateController,
                  decoration:
                      InputDecoration(labelText: widget.loc.plateNumber)),
              TextField(
                  controller: driverController,
                  decoration:
                      InputDecoration(labelText: widget.loc.driverName)),
              TextField(
                  controller: phoneController,
                  decoration:
                      InputDecoration(labelText: widget.loc.driverPhone)),
              TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: widget.loc.capacity)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(widget.loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (plateController.text.isNotEmpty) {
                final bus = Bus(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  plateNumber: plateController.text,
                  driverName: driverController.text,
                  driverPhone: phoneController.text,
                  capacity: int.tryParse(capacityController.text) ?? 40,
                );
                await widget.firebaseService.saveBus(bus);
                Navigator.pop(context);
                _loadBuses();
              }
            },
            child: Text(widget.loc.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loc.manageBuses),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBuses),
          const LanguageToggleButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus,
                          size: 60, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text(widget.loc.noBusesYet,
                          style:
                              GoogleFonts.poppins(color: AppTheme.textMuted)),
                      Text(widget.loc.tapToAdd,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBuses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _buses.length,
                    itemBuilder: (context, index) {
                      final bus = _buses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: bus.isActive
                              ? Border.all(
                                  color: AppTheme.successGreen, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 8)
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bus.plateNumber,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(
                                      '${widget.loc.driver}: ${bus.driverName}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textMuted)),
                                  Text(
                                      '${widget.loc.capacity}: ${bus.capacity}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: bus.isActive
                                        ? AppTheme.successGreen.withAlpha(25)
                                        : AppTheme.errorRed.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    bus.isActive
                                        ? widget.loc.active
                                        : 'Inactive',
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: bus.isActive
                                            ? AppTheme.successGreen
                                            : AppTheme.errorRed),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  onPressed: () async {
                                    await widget.firebaseService
                                        .deleteBus(bus.id);
                                    _loadBuses();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBusDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AdminSettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final FirebaseService firebaseService;
  final AppLocalizations loc;

  const _AdminSettingsScreen(
      {required this.onLogout,
      required this.firebaseService,
      required this.loc});

  @override
  State<_AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<_AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loc.settings),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
        actions: const [LanguageToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
              icon: Icons.school,
              title: widget.loc.schoolInfo,
              onTap: () => _showSchoolInfoDialog()),
          _SettingsTile(
              icon: Icons.notifications,
              title: widget.loc.notifications,
              onTap: () => Navigator.pushNamed(context, '/notifications')),
          const SizedBox(height: 8),
          _SettingsTile(
              icon: Icons.logout,
              title: widget.loc.logout,
              iconColor: AppTheme.errorRed,
              onTap: widget.onLogout),
        ],
      ),
    );
  }

  void _showSchoolInfoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SchoolInfoSheet(
          firebaseService: widget.firebaseService, loc: widget.loc),
    );
  }
}

class _SchoolInfoSheet extends StatelessWidget {
  final FirebaseService firebaseService;
  final AppLocalizations loc;

  const _SchoolInfoSheet({required this.firebaseService, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.school,
                            color: AppTheme.primaryBlue, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart track',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              loc.isArabic
                                  ? 'مدرسة الإمام عبدالملك بن حميد'
                                  : 'Imam Abdulmalik bin Humaid School',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Info cards
                  _InfoRow(
                    label: loc.isArabic
                        ? 'جلان بني بو حسن، جنوب الشرقية'
                        : 'Jalan Bani Bu Hassan, South Eastern',
                    tag: loc.location,
                  ),
                  _InfoRow(
                    label: loc.isArabic
                        ? 'التعليم الأساسي (صف 11-12)'
                        : 'Basic Education (Grades 11-12)',
                    tag: loc.stages,
                  ),
                  _InfoRow(label: '+968 9XXX XXXX', tag: loc.thePhone),
                  const SizedBox(height: 24),
                  // Principal speech
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.secondaryGreen, Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.principalSpeech,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          loc.aboutStudentSafety,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                loc.isArabic
                                    ? 'سلامة طلابنا هي أولويتنا. نحن ملتزمون بتوفير بيئة نقل آمنة ومريحة لجميع الطلاب من خلال نظام المسار الذكي. يتيح لنا هذا النظام مراقبة حافلات المدرسة والتواصل بفعالية مع أولياء الأمور لضمان وصول الطلاب بأمان إلى المدرسة والعودة للمنزل. نعمل وفقاً لرؤية عمان 2040 لتحقيق التميز في التعليم وخدمات المدرسة.'
                                    : '"The safety of our students is our top priority. We are committed to providing a safe and comfortable transport environment for all students through the Intelligent Path System. This system allows us to monitor school buses and communicate effectively with parents to ensure students arrive safely in school and return home. We work in accordance with Oman Vision 2040 to achieve excellence in education and school services."',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white,
                                    height: 1.5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 40),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.isArabic
                              ? 'السيد ناصر بن غريب البلوشي'
                              : 'Mr. Nasser bin Gharib Al-Balushi',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          loc.schoolPrincipal,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.recentActivities,
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _ActivityCard(
                    title: loc.isArabic
                        ? 'تم تسجيل 5 طلاب جدد'
                        : '5 new students registered',
                    time: loc.isArabic ? 'منذ ساعتين' : '2 hours ago',
                    icon: Icons.person_add,
                    color: AppTheme.primaryBlue,
                  ),
                  _ActivityCard(
                    title:
                        loc.isArabic ? 'تم إضافة حافلة جديدة' : 'New bus added',
                    time: loc.isArabic ? 'أمس' : 'Yesterday',
                    icon: Icons.directions_bus,
                    color: AppTheme.accentYellow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String tag;

  const _InfoRow({required this.label, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: GoogleFonts.poppins(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(tag,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(time,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
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
