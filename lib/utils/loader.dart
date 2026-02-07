import 'dart:convert';
import 'dart:typed_data';

import 'package:aiplantidentifier/database/database.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LeafCircleWaveLoader extends StatefulWidget {
  const LeafCircleWaveLoader({super.key});

  @override
  State<LeafCircleWaveLoader> createState() => _LeafCircleWaveLoaderState();
}

class _LeafCircleWaveLoaderState extends State<LeafCircleWaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _CircleWavePainter(progress: _controller.value),
                size: const Size(180, 180),
              );
            },
          ),

          Icon(Icons.eco_rounded, size: 52, color: Colors.white),
        ],
      ),
    );
  }
}

class _CircleWavePainter extends CustomPainter {
  final double progress;

  _CircleWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final outerPaint =
        Paint()
          ..color = const Color(0xFF1B5E20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    canvas.drawCircle(center, size.width / 2 - 6, outerPaint);

    final waveRadius =
        (size.width / 2 - 16) + math.sin(progress * 2 * math.pi) * 6;

    final wavePaint =
        Paint()
          ..color = const Color(0xFF81C784)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    canvas.drawCircle(center, waveRadius, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _CircleWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class LeafRippleLoader extends StatefulWidget {
  const LeafRippleLoader({super.key});

  @override
  State<LeafRippleLoader> createState() => _LeafRippleLoaderState();
}

class _LeafRippleLoaderState extends State<LeafRippleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _RipplePainter(progress: _controller.value),
                size: const Size(200, 200),
              );
            },
          ),

          const Icon(Icons.eco_rounded, size: 40, color: Colors.white),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;

  _RipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: outerRadius)),
    );

    for (int i = 0; i < 2; i++) {
      final waveProgress = (progress + i * 0.35) % 1.0;
      final radius = waveProgress * outerRadius;

      final paint =
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFF81C784).withOpacity(0.0),
                const Color(0xFF81C784).withOpacity(0.9),
              ],
              stops: const [0.7, 1.0],
            ).createShader(Rect.fromCircle(center: center, radius: radius))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;

      canvas.drawCircle(center, radius, paint);
    }

    canvas.restore();

    final outerRingPaint =
        Paint()
          ..color = const Color(0xFF1B5E20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    canvas.drawCircle(center, outerRadius, outerRingPaint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

Widget plantImage(String plantId) {
  return SizedBox(
    width: 64,
    height: 64,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FutureBuilder<Uint8List?>(
        future: DatabaseHelper.instance.getIdentificationImage(
          int.parse(plantId),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primarySwatch,
                ),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }

          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.local_florist),
          );
        },
      ),
    ),
  );
}

Widget plantImagee(String plantId, double d) {
  return FutureBuilder<Uint8List?>(
    future: DatabaseHelper.instance.getIdentificationImage(int.parse(plantId)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircleAvatar(
          radius: 32,
          backgroundColor: Color(0xFFE0E0E0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primarySwatch,
          ),
        );
      }

      if (snapshot.hasData && snapshot.data != null) {
        return CircleAvatar(
          radius: d + 1,
          backgroundImage: MemoryImage(snapshot.data!),
        );
      }

      return const CircleAvatar(
        radius: 32,
        backgroundColor: Color(0xFFE0E0E0),
        child: Icon(Icons.local_florist),
      );
    },
  );
}

String fixEmoji(String value) {
  return utf8.decode(latin1.encode(value));
}

class EmptyStateWidgett extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData fallbackIcon;

  const EmptyStateWidgett({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.buttonText,
    this.onButtonPressed,
    this.fallbackIcon = Icons.local_florist,
  });

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  bool _isLargeTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double maxContentWidth =
        _isLargeTablet(context)
            ? 520
            : _isTablet(context)
            ? 440
            : screenWidth;

    return SafeArea(
      bottom: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _isTablet(context) ? 5 / 3 : 6 / 3,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          fallbackIcon,
                          size: _isTablet(context) ? 96 : 72,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _isTablet(context) ? 22 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E2E2E),
                  ),
                ),

                const SizedBox(height: 12),

                /// DESCRIPTION
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _isTablet(context) ? 15 : 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                if (buttonText != null && onButtonPressed != null) ...[
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        buttonText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
