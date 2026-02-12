// import 'package:aiplantidentifier/core/app_settings.dart';
// import 'package:aiplantidentifier/database/database.dart';
// import 'package:aiplantidentifier/providers/profile_provider.dart';
// import 'package:aiplantidentifier/views/onbaording/onbaording.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   late Animation<double> logoOpacity;
//   late Animation<double> logoScale;
//   late Animation<double> textOpacity;

//   @override
//   void initState() {
//     super.initState();
//     deleteall();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     );

//     logoOpacity = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.33, 0.67, curve: Curves.easeIn),
//       ),
//     );

//     logoScale = Tween<double>(begin: 0.7, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.33, 0.67, curve: Curves.easeOutBack),
//       ),
//     );

//     textOpacity = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.66, 1.0, curve: Curves.easeIn),
//       ),
//     );
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _goToOnboarding();
//       }
//     });

//     _controller.forward();
//   }

//   Future<void> deleteall() async {
//     await DatabaseHelper.instance.deleteAllAppData();
//     await DatabaseHelper.instance.deleteAllData();
//   }

// Future<void> _goToOnboarding() async {
//   final login = await AppSettings.getData(
//     'USER_ISLOGIN',
//     SharedPreferenceIOType.BOOL,
//   );

//   if (!mounted) return;

//   if (login == true) {
//     await Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     ).getUserProfileApi();

//     if (!mounted) return;

//     // Navigator.of(
//     //   context,
//     // ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
//   } else {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//     );
//   }
// }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Color _topColor(double t) {
//     if (t < 0.67) {
//       return const Color(0xFF81C784);
//     }

//     final progress = ((t - 0.67) / (0.9 - 0.67)).clamp(0.0, 1.0);

//     return Color.lerp(
//       const Color(0xFF81C784),
//       const Color(0xFF1B5E20),
//       progress,
//     )!;
//   }

//   Color _bottomColor(double t) {
//     if (t < 0.67) {
//       return const Color(0xFF1B5E20);
//     }

//     final progress = ((t - 0.67) / (0.9 - 0.67)).clamp(0.0, 1.0);

//     return Color.lerp(
//       const Color(0xFF1B5E20),
//       const Color(0xFF81C784),
//       progress,
//     )!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: _controller,
//         builder: (_, __) {
//           final t = _controller.value;

//           return Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   // gradient: LinearGradient(
//                   //   begin: Alignment.topCenter,
//                   //   end: Alignment.bottomCenter,
//                   //   colors: [_topColor(t), _bottomColor(t)],
//                   // ),
//                 ),
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       FadeTransition(
//                         opacity: logoOpacity,
//                         child: ScaleTransition(
//                           scale: logoScale,
//                           child: Image.asset(
//                             'images/app_logo2.png',
//                             width: 250,
//                             height: 250,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       // FadeTransition(
//                       //   opacity: textOpacity,
//                       //   child: Text(
//                       //     "FloraScan",
//                       //     style: GoogleFonts.nunitoSans(
//                       //       fontSize: 26,
//                       //       fontWeight: FontWeight.bold,
//                       //       color: Colors.white,
//                       //       letterSpacing: 1,
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: -80,
//                 right: -60,
//                 child: Opacity(
//                   opacity: 0.2,
//                   child: FadeTransition(
//                     opacity: textOpacity,
//                     child: Icon(Icons.eco, color: Colors.white, size: 400),
//                   ),
//                   // child:
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/database/database.dart';
import 'package:aiplantidentifier/providers/profile_provider.dart';
import 'package:aiplantidentifier/views/mainscrens/mainscreen.dart';
import 'package:aiplantidentifier/views/onbaording/onbaording.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> revealAnimation;

  @override
  void initState() {
    super.initState();

    deleteall();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000), // 5 seconds total
    );

    // Open: 1.5s (30%) → Stay: 2s (40%) → Close: 1.5s (30%)
    revealAnimation = TweenSequence<double>([
      // Opening: 1.5 seconds (1.5/5 = 30%)
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      // Stay open: 2 seconds (2/5 = 40%)
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      // Closing: 1.5 seconds (1.5/5 = 30%)
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.addListener(() {
      // 70% = 30% open + 40% stay
      if (_controller.value >= 0.7) {
        _controller.stop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ClipRect(
          child: AnimatedBuilder(
            animation: revealAnimation,
            builder: (context, child) {
              final isOpening = _controller.value <= 0.5;
              return Align(
                alignment:
                    isOpening ? Alignment.centerRight : Alignment.centerLeft,
                widthFactor: revealAnimation.value,
                child: child,
              );
            },
            child: Image.asset(
              'images/app_logo2.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
