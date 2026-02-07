import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF1C5E20);

class AppTheme {
  /// Light Theme
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      hoverColor: Colors.transparent,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      splashColor: AppColors.primaryColor.withOpacity(0.2),
      highlightColor: AppColors.primaryColor.withOpacity(0.1),
      primarySwatch: AppColors.primarySwatch,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, // drawer, back icons color
          size: 30, // icon size
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySwatch[700]!;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: AppColors.primaryColor),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.primaryColor),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryColor.withOpacity(0.1),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        hintStyle: TextStyle(color: AppColors.primaryColor.withOpacity(0.5)),
      ),

      colorScheme:
          ColorScheme.fromSwatch(
            primarySwatch: AppColors.primarySwatch,
          ).copyWith(
            primary: AppColors.primaryColor,
            secondary: AppColors.primaryColor,
          ),

      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: AppColors.primaryColor,
      ),
    );
  }

  /// Dark Theme
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primarySwatch[700],
      scaffoldBackgroundColor: const Color(0xFF121212),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primarySwatch[700],
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor,
        selectionColor: AppColors.primaryColor.withOpacity(0.5),
        selectionHandleColor: AppColors.primaryColor,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySwatch[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySwatch[700]!;
          }
          return Colors.grey.shade600;
        }),
        side: BorderSide(color: AppColors.primarySwatch[700]!),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.primarySwatch[700]),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primarySwatch[700]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),

      textTheme: Theme.of(
        context,
      ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    );
  }
}
