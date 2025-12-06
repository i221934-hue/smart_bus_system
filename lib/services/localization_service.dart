import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized localization service for Arabic/English translations
/// Uses ValueNotifier for in-place UI updates without navigation
class AppLocalizations extends ChangeNotifier {
  static final AppLocalizations _instance = AppLocalizations._internal();
  factory AppLocalizations() => _instance;
  AppLocalizations._internal();

  static const String _langKey = 'app_language';
  bool _isArabic = false;

  bool get isArabic => _isArabic;
  TextDirection get textDirection =>
      _isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isArabic = prefs.getBool(_langKey) ?? false;
    notifyListeners();
  }

  /// Toggle language and notify all listeners for in-place translation
  Future<void> toggleLanguage() async {
    _isArabic = !_isArabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_langKey, _isArabic);
    notifyListeners(); // This triggers rebuild of all listening widgets
  }

  // ==================== COMMON ====================
  String get appName => _isArabic ? 'مسار سمارت' : 'MASAR SMART';
  String get welcome => _isArabic ? 'مرحباً بك' : 'Welcome Back';
  String get signIn => _isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get signUp => _isArabic ? 'إنشاء حساب' : 'Sign Up';
  String get createAccount => _isArabic ? 'إنشاء حساب جديد' : 'Create Account';
  String get email => _isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => _isArabic ? 'كلمة المرور' : 'Password';
  String get confirmPassword =>
      _isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get fullName => _isArabic ? 'الاسم الكامل' : 'Full Name';
  String get phone => _isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get save => _isArabic ? 'حفظ' : 'Save';
  String get cancel => _isArabic ? 'إلغاء' : 'Cancel';
  String get add => _isArabic ? 'إضافة' : 'Add';
  String get delete => _isArabic ? 'حذف' : 'Delete';
  String get settings => _isArabic ? 'الإعدادات' : 'Settings';
  String get profile => _isArabic ? 'الملف الشخصي' : 'Profile';
  String get notifications => _isArabic ? 'الإشعارات' : 'Notifications';
  String get language => _isArabic ? 'اللغة' : 'Language';
  String get help => _isArabic ? 'المساعدة' : 'Help & Support';
  String get logout => _isArabic ? 'تسجيل الخروج' : 'Logout';
  String get home => _isArabic ? 'الرئيسية' : 'Home';
  String get location => _isArabic ? 'الموقع' : 'Location';
  String get thePhone => _isArabic ? 'الهاتف' : 'The phone';
  String get stages => _isArabic ? 'المراحل' : 'Stages';

  // ==================== ROLES ====================
  String get iAmA => _isArabic ? 'أنا:' : 'I am a:';
  String get parent => _isArabic ? 'ولي أمر' : 'Parent';
  String get driver => _isArabic ? 'سائق' : 'Driver';
  String get admin => _isArabic ? 'مشرف' : 'Admin';
  String get schoolAdmin => _isArabic ? 'مدير المدرسة' : 'School Admin';

  // ==================== AUTH ====================
  String get dontHaveAccount =>
      _isArabic ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get alreadyHaveAccount =>
      _isArabic ? 'لديك حساب بالفعل؟' : 'Already have an account?';
  String get signInToContinue =>
      _isArabic ? 'سجل للمتابعة' : 'Sign in to continue';
  String get joinMasar =>
      _isArabic ? 'انضم إلى مسار سمارت' : 'Join MASAR SMART';

  // ==================== PARENT ====================
  String get myChildren => _isArabic ? 'أطفالي' : 'My Children';
  String get trackBus => _isArabic ? 'تتبع الحافلة' : 'Track Bus';
  String get noStudentsLinked =>
      _isArabic ? 'لا يوجد طلاب مرتبطين' : 'No students linked yet';
  String get contactAdmin => _isArabic
      ? 'اتصل بمدير المدرسة لربط أطفالك'
      : 'Contact your school admin to link your children';
  String get estimatedArrival =>
      _isArabic ? 'وقت الوصول المتوقع' : 'Estimated arrival';
  String get minutes => _isArabic ? 'دقائق' : 'mins';

  // ==================== DRIVER ====================
  String get driverDashboard => _isArabic ? 'لوحة السائق' : 'Driver Dashboard';
  String get tripStatus => _isArabic ? 'حالة الرحلة' : 'Trip Status';
  String get startTrip => _isArabic ? 'بدء الرحلة' : 'Start Trip';
  String get stopTrip => _isArabic ? 'إنهاء الرحلة' : 'Stop Trip';
  String get inProgress => _isArabic ? 'جارية' : 'In Progress';
  String get notStarted => _isArabic ? 'لم تبدأ' : 'Not Started';
  String get tripEnded => _isArabic ? 'انتهت الرحلة' : 'Trip Ended';
  String get onBoard => _isArabic ? 'على متن الحافلة' : 'On Board';
  String get droppedOff => _isArabic ? 'تم الإنزال' : 'Dropped Off';
  String get tripMap => _isArabic ? 'خريطة الرحلة' : 'Trip Map';
  String get students => _isArabic ? 'الطلاب' : 'Students';
  String get noStudentsAssigned =>
      _isArabic ? 'لا يوجد طلاب مخصصين' : 'No students assigned';
  String get speed => _isArabic ? 'السرعة' : 'Speed';
  String get gpsActive => _isArabic ? 'GPS نشط' : 'GPS Active';
  String get gpsInactive => _isArabic ? 'GPS متوقف' : 'GPS Inactive';
  String get locationPermissionRequired =>
      _isArabic ? 'مطلوب إذن الموقع' : 'Location permission required';
  String get enableLocation => _isArabic ? 'تفعيل الموقع' : 'Enable Location';
  String get openSettings => _isArabic ? 'فتح الإعدادات' : 'Open Settings';

  // ==================== ADMIN / CONTROL PANEL ====================
  String get dashboard => _isArabic ? 'لوحة التحكم' : 'Dashboard';
  String get controlPanel => _isArabic ? 'لوحة التحكم' : 'Control Panel';
  String get overviewStats => _isArabic
      ? 'نظرة عامة على إحصائيات النقل المدرسي'
      : 'Overview of School Transport Statistics';
  String get totalStudents => _isArabic ? 'إجمالي الطلاب' : 'Total Students';
  String get studentsRegistered =>
      _isArabic ? 'طلاب مسجلين في النظام' : 'Students registered in the system';
  String get fromLastMonth => _isArabic ? 'من الشهر الماضي' : 'from last month';
  String get supervisors => _isArabic ? 'المشرفون' : 'Supervisors';
  String get activeSupervisors =>
      _isArabic ? 'مشرفون نشطون' : 'Active Supervisors';
  String get schoolBuses => _isArabic ? 'الحافلات المدرسية' : 'School buses';
  String get busesInService =>
      _isArabic ? 'حافلات في الخدمة' : 'Buses in service';
  String get newEntry => _isArabic ? 'إدخال جديد' : 'New entry';
  String get thisWeek => _isArabic ? 'هذا الأسبوع' : 'This week';
  String get quickActions => _isArabic ? 'إجراءات سريعة' : 'Quick Actions';
  String get addStudent => _isArabic ? 'إضافة طالب' : 'Add Student';
  String get addBus => _isArabic ? 'إضافة حافلة' : 'Add Bus';
  String get createTrip => _isArabic ? 'إنشاء رحلة' : 'Create Trip';
  String get reports => _isArabic ? 'التقارير' : 'Reports';
  String get manageStudents => _isArabic ? 'إدارة الطلاب' : 'Manage Students';
  String get manageBuses => _isArabic ? 'إدارة الحافلات' : 'Manage Buses';
  String get buses => _isArabic ? 'الحافلات' : 'Buses';
  String get trips => _isArabic ? 'الرحلات' : 'Trips';
  String get noStudentsYet =>
      _isArabic ? 'لا يوجد طلاب بعد' : 'No students yet';
  String get noBusesYet => _isArabic ? 'لا يوجد حافلات بعد' : 'No buses yet';
  String get tapToAdd => _isArabic ? 'اضغط + للإضافة' : 'Tap + to add';
  String get studentName => _isArabic ? 'اسم الطالب' : 'Student Name';
  String get className => _isArabic ? 'الصف' : 'Class';
  String get parentName => _isArabic ? 'اسم ولي الأمر' : 'Parent Name';
  String get parentPhone => _isArabic ? 'هاتف ولي الأمر' : 'Parent Phone';
  String get plateNumber => _isArabic ? 'رقم اللوحة' : 'Plate Number';
  String get driverName => _isArabic ? 'اسم السائق' : 'Driver Name';
  String get driverPhone => _isArabic ? 'هاتف السائق' : 'Driver Phone';
  String get capacity => _isArabic ? 'السعة' : 'Capacity';
  String get morning => _isArabic ? 'صباحي' : 'Morning';
  String get afternoon => _isArabic ? 'مسائي' : 'Afternoon';
  String get create => _isArabic ? 'إنشاء' : 'Create';

  // ==================== SCHOOL INFO ====================
  String get schoolInfo => _isArabic ? 'معلومات المدرسة' : 'School Information';
  String get principalSpeech =>
      _isArabic ? 'كلمة مدير المدرسة' : "The school principal's speech";
  String get aboutStudentSafety =>
      _isArabic ? 'حول سلامة الطلاب' : 'About Student Safety';
  String get recentActivities =>
      _isArabic ? 'الأنشطة الأخيرة' : 'Recent Activities';
  String get schoolPrincipal => _isArabic ? 'مدير المدرسة' : 'School Principal';
  String get basicEducation =>
      _isArabic ? 'التعليم الأساسي' : 'Basic Education';

  // ==================== STUDENT STATUS ====================
  String get atHome => _isArabic ? 'في المنزل' : 'At Home';
  String get arrived => _isArabic ? 'وصل' : 'Arrived';
  String get active => _isArabic ? 'نشط' : 'Active';

  // ==================== NOTIFICATIONS ====================
  String get busStarted => _isArabic ? 'انطلقت الحافلة' : 'Bus Started';
  String get childPickedUp => _isArabic ? 'تم استلام الطفل' : 'Child Picked Up';
  String get arrivedAtSchool =>
      _isArabic ? 'وصل إلى المدرسة' : 'Arrived at School';
  String get notificationControl =>
      _isArabic ? 'التحكم بالإشعارات' : 'Notification Control';
  String get chat => _isArabic ? 'المحادثة' : 'Chat';
  String get busNear => _isArabic ? 'الحافلة قريبة' : 'Bus Near';
  String get busHere => _isArabic ? 'الحافلة وصلت' : 'Bus Here';
  String get endTrip => _isArabic ? 'انتهاء الرحلة' : 'End trip';
  String get startTripNotif => _isArabic ? 'بداية الرحلة' : 'Start trip';
  String get onBoardNotif => _isArabic ? 'على متن الحافلة' : 'On Board';
  String get arriveNotif => _isArabic ? 'الوصول' : 'Arrive';
  String get saveAll => _isArabic ? 'حفظ الكل' : 'Save All';

  // ==================== SPLASH ====================
  String get schoolBusTracking =>
      _isArabic ? 'تتبع حافلة المدرسة' : 'SCHOOL BUS TRACKING';
  String get studentSafety =>
      _isArabic ? 'سلامة الطلاب هي عملنا' : 'Student safety is our business';

  // ==================== VALIDATION ====================
  String get pleaseEnterEmail =>
      _isArabic ? 'الرجاء إدخال البريد الإلكتروني' : 'Please enter your email';
  String get pleaseEnterValidEmail =>
      _isArabic ? 'الرجاء إدخال بريد صحيح' : 'Please enter a valid email';
  String get pleaseEnterPassword =>
      _isArabic ? 'الرجاء إدخال كلمة المرور' : 'Please enter your password';
  String get passwordMinLength => _isArabic
      ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
      : 'Password must be at least 6 characters';
  String get passwordsDoNotMatch =>
      _isArabic ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';
  String get pleaseEnterName =>
      _isArabic ? 'الرجاء إدخال الاسم' : 'Please enter your name';
  String get pleaseEnterPhone =>
      _isArabic ? 'الرجاء إدخال رقم الهاتف' : 'Please enter your phone number';

  // ==================== TOGGLE BUTTON ====================
  String get switchToArabic => _isArabic ? 'English' : 'العربية';

  // ==================== GPS MESSAGES ====================
  String get trackingStarted => _isArabic ? 'بدأ التتبع' : 'Tracking started';
  String get trackingStopped =>
      _isArabic ? 'تم إيقاف التتبع' : 'Tracking stopped';
  String get locationServiceDisabled =>
      _isArabic ? 'خدمة الموقع معطلة' : 'Location service is disabled';
  String get locationPermissionDenied =>
      _isArabic ? 'تم رفض إذن الموقع' : 'Location permission denied';
  String get locationPermissionDeniedForever => _isArabic
      ? 'تم رفض إذن الموقع بشكل دائم. يرجى تمكينه من الإعدادات'
      : 'Location permission permanently denied. Please enable from settings';
  String get gettingLocation =>
      _isArabic ? 'جاري الحصول على الموقع...' : 'Getting location...';
}

/// Language Toggle Widget - uses setState for in-place translation
class LanguageToggleButton extends StatefulWidget {
  final bool showLabel;

  const LanguageToggleButton({super.key, this.showLabel = true});

  @override
  State<LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<LanguageToggleButton> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();

    return TextButton.icon(
      onPressed: () async {
        await loc.toggleLanguage();
        // Parent widget will rebuild via listener
      },
      icon: const Icon(Icons.language, size: 20),
      label: Text(
        loc.switchToArabic,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withAlpha(30),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

/// Dark theme language toggle for non-blue backgrounds
class LanguageToggleButtonDark extends StatefulWidget {
  const LanguageToggleButtonDark({super.key});

  @override
  State<LanguageToggleButtonDark> createState() =>
      _LanguageToggleButtonDarkState();
}

class _LanguageToggleButtonDarkState extends State<LanguageToggleButtonDark> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();

    return TextButton.icon(
      onPressed: () => loc.toggleLanguage(),
      icon:
          Icon(Icons.language, size: 20, color: Theme.of(context).primaryColor),
      label: Text(
        loc.switchToArabic,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(20),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
