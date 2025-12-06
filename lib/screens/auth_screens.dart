import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _authService = AuthService();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    AppLocalizations().addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppLocalizations().removeListener(_onLanguageChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      debugPrint('=== LOGIN ATTEMPT ===');
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint('=== LOGIN RESULT: ${result.success} ===');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success && result.user != null) {
        String route = '/parent-home';
        switch (result.user!.role) {
          case UserRole.parent:
            route = '/parent-home';
          case UserRole.driver:
            route = '/driver-home';
          case UserRole.admin:
            route = '/admin-home';
        }
        Navigator.pushReplacementNamed(context, route);
      } else {
        _showError(result.message);
      }
    } catch (e) {
      debugPrint('=== LOGIN ERROR: $e ===');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Login error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return LocalizedScreen(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryBlue, Color(0xFF2D4A6F)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
                        child: Column(
                          children: [
                            // Language toggle
                            Align(
                              alignment: loc.isArabic
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: const LanguageToggleButton(),
                            ),
                            const SizedBox(height: 20),
                            // Logo
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 20)
                                ],
                              ),
                              child: Icon(Icons.directions_bus,
                                  size: 60, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.appName,
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              loc.schoolBusTracking,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                            // Form Card - Flexible to take remaining space
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        loc.welcome,
                                        style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark),
                                      ),
                                      Text(
                                        loc.signInToContinue,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: AppTheme.textMuted),
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _passwordFocus.requestFocus(),
                                        decoration: InputDecoration(
                                          labelText: loc.email,
                                          prefixIcon:
                                              const Icon(Icons.email_outlined),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return loc.pleaseEnterEmail;
                                          }
                                          if (!value.contains('@')) {
                                            return loc.pleaseEnterValidEmail;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocus,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        onTap: _scrollToBottom,
                                        onFieldSubmitted: (_) => _login(),
                                        decoration: InputDecoration(
                                          labelText: loc.password,
                                          prefixIcon:
                                              const Icon(Icons.lock_outlined),
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility),
                                            onPressed: () => setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return loc.pleaseEnterPassword;
                                          }
                                          if (value.length < 6) {
                                            return loc.passwordMinLength;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 54,
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.primaryBlue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2))
                                              : Text(loc.signIn,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(loc.dontHaveAccount,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70)),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/signup'),
                                  child: Text(loc.signUp,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _scrollController = ScrollController();
  final _authService = AuthService();
  UserRole _selectedRole = UserRole.parent;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    AppLocalizations().addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppLocalizations().removeListener(_onLanguageChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _scrollToField() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      debugPrint('=== SIGNUP ATTEMPT ===');
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
      debugPrint('=== SIGNUP RESULT: ${result.success} ===');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        String route = '/parent-home';
        switch (_selectedRole) {
          case UserRole.parent:
            route = '/parent-home';
          case UserRole.driver:
            route = '/driver-home';
          case UserRole.admin:
            route = '/admin-home';
        }
        Navigator.pushReplacementNamed(context, route);
      } else {
        _showError(result.message);
      }
    } catch (e) {
      debugPrint('=== SIGNUP ERROR: $e ===');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Signup error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return LocalizedScreen(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryBlue, Color(0xFF2D4A6F)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Fixed header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                      const LanguageToggleButton(),
                    ],
                  ),
                ),
                Text(
                  loc.joinMasar,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                // Scrollable form
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.iAmA,
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _RoleChip(
                                    label: loc.parent,
                                    icon: Icons.family_restroom,
                                    selected: _selectedRole == UserRole.parent,
                                    onTap: () => setState(
                                        () => _selectedRole = UserRole.parent)),
                                const SizedBox(width: 8),
                                _RoleChip(
                                    label: loc.driver,
                                    icon: Icons.directions_bus,
                                    selected: _selectedRole == UserRole.driver,
                                    onTap: () => setState(
                                        () => _selectedRole = UserRole.driver)),
                                const SizedBox(width: 8),
                                _RoleChip(
                                    label: loc.admin,
                                    icon: Icons.admin_panel_settings,
                                    selected: _selectedRole == UserRole.admin,
                                    onTap: () => setState(
                                        () => _selectedRole = UserRole.admin)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: loc.fullName,
                                  prefixIcon:
                                      const Icon(Icons.person_outlined)),
                              validator: (v) => v == null || v.isEmpty
                                  ? loc.pleaseEnterName
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: loc.email,
                                  prefixIcon: const Icon(Icons.email_outlined)),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return loc.pleaseEnterEmail;
                                if (!v.contains('@'))
                                  return loc.pleaseEnterValidEmail;
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: loc.phone,
                                  prefixIcon: const Icon(Icons.phone_outlined)),
                              validator: (v) => v == null || v.isEmpty
                                  ? loc.pleaseEnterPhone
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              onTap: _scrollToField,
                              decoration: InputDecoration(
                                labelText: loc.password,
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return loc.pleaseEnterPassword;
                                if (v.length < 6) return loc.passwordMinLength;
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onTap: _scrollToField,
                              onFieldSubmitted: (_) => _signup(),
                              decoration: InputDecoration(
                                  labelText: loc.confirmPassword,
                                  prefixIcon: const Icon(Icons.lock_outlined)),
                              validator: (v) {
                                if (v != _passwordController.text) {
                                  return loc.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : Text(loc.createAccount,
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(loc.alreadyHaveAccount,
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.textMuted,
                                        fontSize: 13)),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(loc.signIn,
                                      style: GoogleFonts.poppins(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
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
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBlue : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: selected ? null : Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.white : AppTheme.textMuted,
                  size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
