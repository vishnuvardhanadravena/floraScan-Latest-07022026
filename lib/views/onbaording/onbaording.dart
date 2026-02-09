import 'package:aiplantidentifier/views/login_Screen.dart';
import 'package:aiplantidentifier/views/mainscrens/mainscreen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Identify Plants\nInstantly',
      description:
          'Scan any plant around you and get instant information about its name, species, and characteristics.',
      imageUrl: "images/onboarding1.png",
      showScanner: true,
    ),
    OnboardingData(
      title: 'Know How to Care',
      description:
          'Get simple care tips like watering, sunlight, and growth conditions to keep your plants healthy.',
      imageUrl: "images/onboarding2.png",
      showScanner: false,
    ),
    OnboardingData(
      title: 'Grow with\nConfidence',
      description:
          'Save your plants, track their growth, and become a better plant parent every day.',
      imageUrl: "images/onboarding3.png",
      showScanner: false,
    ),
  ];

  void _onContinue() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      // MaterialPageRoute(builder: (_) => const MainScreen()),
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _onGetStarted() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return OnboardingPage(data: _pages[index]);
              },
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.42,
                padding: EdgeInsets.all(size.width * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF1B5E20).withOpacity(0.6),
                      const Color(0xFF1B5E20),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _pages[_currentPage].title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.075,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),

                    Expanded(
                      child: Text(
                        _pages[_currentPage].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: size.width * 0.04,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.01,
                          ),
                          child: LeafIndicator(isActive: index == _currentPage),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF047857),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.006,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                        ),
                      ),
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
  // @override
  //   void initState() {
  //     super.initState();
  //   }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(child: Image.asset(data.imageUrl, fit: BoxFit.cover)),

        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),
        if (data.showScanner)
          Positioned(
            top: size.height * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: size.width * 0.7,
                child: const ScannerFrame(),
              ),
            ),
          ),
      ],
    );
  }
}

class ScannerFrame extends StatefulWidget {
  const ScannerFrame({super.key});

  @override
  State<ScannerFrame> createState() => _ScannerFrameState();
}

class _ScannerFrameState extends State<ScannerFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double frameHeight = size.height * 0.32;
    final double cornerSize = size.width * 0.08;
    final double lineHeight = size.height * 0.005;
    final double scanAreaHeight = frameHeight - (cornerSize * 0.9);

    return SizedBox(
      height: frameHeight,
      child: Stack(
        children: [
          Positioned.fill(child: _CornerBorder(cornerSize: cornerSize)),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double topOffset =
                  cornerSize + (_controller.value * scanAreaHeight);
              return Positioned(
                top: topOffset - size.height * 0.012,
                left: cornerSize + size.width * 0.025,
                right: cornerSize + size.width * 0.025,
                child: Container(
                  height: lineHeight,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 246, 248, 247),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
                        blurRadius: size.width * 0.02,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CornerBorder extends StatelessWidget {
  final double cornerSize;

  const _CornerBorder({required this.cornerSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Corner(top: 0, left: 0, angle: 0, cornerSize: cornerSize),
        _Corner(top: 0, right: 0, angle: 90, cornerSize: cornerSize),
        _Corner(bottom: 0, right: 0, angle: 180, cornerSize: cornerSize),
        _Corner(bottom: 0, left: 0, angle: 270, cornerSize: cornerSize),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final double? top, left, right, bottom;
  final double angle;
  final double cornerSize;

  const _Corner({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.angle,
    required this.cornerSize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle * 3.141592653589793 / 180,
        child: SizedBox(
          width: cornerSize,
          height: cornerSize,
          child: CustomPaint(painter: _CornerPainter(cornerSize: cornerSize)),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double cornerSize;

  _CornerPainter({required this.cornerSize});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = cornerSize * 0.5;

    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = cornerSize * 0.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(0, size.height)
          ..lineTo(0, radius)
          ..arcToPoint(
            Offset(radius, 0),
            radius: Radius.circular(radius),
            clockwise: true,
          )
          ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LeafIndicator extends StatelessWidget {
  final bool isActive;

  const LeafIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Icon(
      Icons.eco,
      color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
      size: isActive ? size.width * 0.06 : size.width * 0.05,
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imageUrl;
  final bool showScanner;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.showScanner,
  });
}
