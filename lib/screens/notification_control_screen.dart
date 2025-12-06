import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../services/data_service.dart';
import '../services/localization_service.dart';

class NotificationControlScreen extends ConsumerWidget {
  const NotificationControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final loc = AppLocalizations();
    final dataService = DataService();

    return Directionality(
      textDirection: loc.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.notificationControl),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          actions: const [LanguageToggleButton()],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active,
                        color: AppTheme.primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.isArabic
                            ? 'قم بتخصيص الإشعارات التي تريد استلامها'
                            : 'Customize the notifications you want to receive',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _NotifToggle(
                label: loc.chat,
                subtitle: loc.isArabic ? 'رسائل المحادثة' : 'Chat messages',
                icon: Icons.chat_bubble_outline,
                value: settings.chat,
                onChanged: (value) => notifier.toggleChat(value),
              ),
              _NotifToggle(
                label: loc.busNear,
                subtitle: loc.isArabic
                    ? 'تنبيه عند اقتراب الحافلة'
                    : 'Alert when bus is nearby',
                icon: Icons.near_me,
                value: settings.busNear,
                onChanged: (value) => notifier.toggleBusNear(value),
              ),
              _NotifToggle(
                label: loc.busHere,
                subtitle: loc.isArabic
                    ? 'تنبيه وصول الحافلة'
                    : 'Alert when bus arrives',
                icon: Icons.location_on,
                value: settings.busHere,
                onChanged: (value) => notifier.toggleBusHere(value),
              ),
              _NotifToggle(
                label: loc.endTrip,
                subtitle: loc.isArabic
                    ? 'تنبيه انتهاء الرحلة'
                    : 'Trip end notification',
                icon: Icons.flag,
                value: settings.endTrip,
                onChanged: (value) => notifier.toggleEndTrip(value),
              ),
              _NotifToggle(
                label: loc.startTripNotif,
                subtitle: loc.isArabic
                    ? 'تنبيه بداية الرحلة'
                    : 'Trip start notification',
                icon: Icons.play_circle_outline,
                value: settings.startTrip,
                onChanged: (value) => notifier.toggleStartTrip(value),
              ),
              _NotifToggle(
                label: loc.onBoardNotif,
                subtitle: loc.isArabic
                    ? 'تنبيه صعود الطالب'
                    : 'Student boarded notification',
                icon: Icons.person_add,
                value: settings.onBoard,
                onChanged: (value) => notifier.toggleOnBoard(value),
              ),
              _NotifToggle(
                label: loc.arriveNotif,
                subtitle: loc.isArabic
                    ? 'تنبيه وصول الطالب'
                    : 'Student arrived notification',
                icon: Icons.school,
                value: settings.arrive,
                onChanged: (value) => notifier.toggleArrive(value),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await dataService.saveNotificationSettings(settings);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.isArabic
                              ? 'تم حفظ الإعدادات'
                              : 'Settings saved'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: Text(
                    loc.saveAll,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
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
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.successGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
