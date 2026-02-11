import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  static void success(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF2D5F3F),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  static void error(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
// import 'package:flutter/material.dart';

enum ToastType { success, error }

class CustomToast extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback? onDismiss;

  const CustomToast({
    Key? key,
    required this.message,
    this.type = ToastType.success,
    this.duration = const Duration(seconds: 2),
    this.onDismiss,
  }) : super(key: key);

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for slide and fade
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Animation controller for progress bar
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animations
    _animationController.forward();
    _progressController.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            widget.onDismiss?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        widget.type == ToastType.success
            ? const Color(0xFF4CAF50)
            : const Color(0xFFF44336);

    final Color progressColor =
        widget.type == ToastType.success
            ? const Color(0xFF45a049)
            : const Color(0xFFda190b);

    final IconData icon =
        widget.type == ToastType.success ? Icons.check_circle : Icons.error;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 8,
                  color: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _animationController.reverse().then((_) {
                              widget.onDismiss?.call();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: LinearProgressIndicator(
                        value: 1.0 - _progressController.value,
                        minHeight: 4,
                        backgroundColor: backgroundColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor.withOpacity(0.85),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

OverlayEntry? _currentToastEntry;

void showCustomToast(
  BuildContext context, {
  required String message,
  ToastType type = ToastType.success,
  Duration duration = const Duration(seconds: 2),
}) {
  _currentToastEntry?.remove();

  _currentToastEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: CustomToast(
            message: message,
            type: type,
            duration: duration,
            onDismiss: () {
              _currentToastEntry?.remove();
              _currentToastEntry = null;
            },
          ),
        ),
  );

  Overlay.of(context).insert(_currentToastEntry!);
}

void showSuccessToast(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
}) {
  showCustomToast(
    context,
    message: message,
    type: ToastType.success,
    duration: duration,
  );
}

void showErrorToast(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
}) {
  showCustomToast(
    context,
    message: message,
    type: ToastType.error,
    duration: duration,
  );
}
