import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    (backgroundColor ?? AppTheme.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 48,
                color: backgroundColor ?? AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
          Row(
            children: [
              Text(
                value ? 'ON' : 'OFF',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: value ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.successGreen,
                activeTrackColor: AppTheme.successGreen.withOpacity(0.3),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppTheme.errorRed.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final String name;
  final String className;
  final String status;
  final String? note;
  final VoidCallback? onTap;

  const StudentCard({
    super.key,
    required this.name,
    required this.className,
    required this.status,
    this.note,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'on_board':
        return AppTheme.successGreen;
      case 'arrived':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.accentYellow;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'on_board':
        return 'On Board';
      case 'arrived':
        return 'Arrived';
      default:
        return 'At Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Class: $className',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(
                'Note: $note',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusCard extends StatelessWidget {
  final String plateNumber;
  final String driverName;
  final int capacity;
  final bool isActive;
  final VoidCallback? onTap;

  const BusCard({
    super.key,
    required this.plateNumber,
    required this.driverName,
    required this.capacity,
    required this.isActive,
    this.onTap,
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
          border: isActive
              ? Border.all(color: AppTheme.successGreen, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.directions_bus,
                color: AppTheme.accentYellow,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plateNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Driver: $driverName',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    'Capacity: $capacity students',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.successGreen.withOpacity(0.1)
                    : AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
