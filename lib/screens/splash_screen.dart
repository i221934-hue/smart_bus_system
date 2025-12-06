import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppTheme.primaryBlue.withAlpha(25),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryBlue,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withAlpha(50),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Shield Icon
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.shield,
                                      size: 40,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    const Positioned(
                                      bottom: 8,
                                      child: Icon(
                                        Icons.star,
                                        size: 16,
                                        color: AppTheme.accentYellow,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Bus with path
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Curved Path
                                    CustomPaint(
                                      size: const Size(100, 40),
                                      painter: _CurvedPathPainter(),
                                    ),
                                    // Bus Icon
                                    Icon(
                                      Icons.directions_bus,
                                      size: 50,
                                      color: AppTheme.accentYellow,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // MASAR Text
                                Text(
                                  'MASAR',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                Text(
                                  'SMART',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SCHOOL BUS TRACKING',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Student safety is our business',
                        style: GoogleFonts.dancingScript(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CurvedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.secondaryGreen
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
