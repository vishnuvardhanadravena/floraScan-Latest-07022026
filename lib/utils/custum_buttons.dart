import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final Widget? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final defaultHeight = size.height * 0.065;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? defaultHeight,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon ?? const SizedBox.shrink(),
              label: Text(text),
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor ?? const Color(0xFF2D5F3F),
                side: BorderSide(
                  color: backgroundColor ?? const Color(0xFF2D5F3F),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon ?? const SizedBox.shrink(),
              label: Text(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? const Color(0xFF2D5F3F),
                foregroundColor: textColor ?? Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
    );
  }
}