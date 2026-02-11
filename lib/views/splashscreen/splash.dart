import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/database/database.dart';
import 'package:aiplantidentifier/providers/profile_provider.dart';
import 'package:aiplantidentifier/views/mainscrens/mainscreen.dart';
import 'package:aiplantidentifier/views/onbaording/onbaording.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> logoOpacity;
  late Animation<double> logoScale;
  late Animation<double> textOpacity;

  @override
  void initState() {
    super.initState();
    deleteall();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.67, curve: Curves.easeIn),
      ),
    );

    logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.67, curve: Curves.easeOutBack),
      ),
    );

    textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToOnboarding();
      }
    });

    _controller.forward();
  }

  Future<void> deleteall() async {
    await DatabaseHelper.instance.deleteAllAppData();
    await DatabaseHelper.instance.deleteAllData();
  }

  Future<void> _goToOnboarding() async {
    final login = await AppSettings.getData(
      'USER_ISLOGIN',
      SharedPreferenceIOType.BOOL,
    );

    if (!mounted) return;

    if (login == true) {
      await Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).getUserProfileApi();

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _topColor(double t) {
    if (t < 0.67) {
      return const Color(0xFF81C784);
    }

    final progress = ((t - 0.67) / (0.9 - 0.67)).clamp(0.0, 1.0);

    return Color.lerp(
      const Color(0xFF81C784),
      const Color(0xFF1B5E20),
      progress,
    )!;
  }

  Color _bottomColor(double t) {
    if (t < 0.67) {
      return const Color(0xFF1B5E20);
    }

    final progress = ((t - 0.67) / (0.9 - 0.67)).clamp(0.0, 1.0);

    return Color.lerp(
      const Color(0xFF1B5E20),
      const Color(0xFF81C784),
      progress,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_topColor(t), _bottomColor(t)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: logoOpacity,
                    child: ScaleTransition(
                      scale: logoScale,
                      child: Image.asset(
                        'images/mdi_leaf.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: textOpacity,
                    child: Text(
                      "FloraScan",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
