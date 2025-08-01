import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const JobApplicationApp());
}

class JobApplicationApp extends StatelessWidget {
  const JobApplicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profesh Job Application',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ThemeColors.black.color,
        colorScheme: ColorScheme.dark(
          primary: ThemeColors.lime500.color,
          primaryContainer: ThemeColors.lime700.color,
          secondary: ThemeColors.mauve300.color,
          secondaryContainer: ThemeColors.mauve500.color,
          tertiary: ThemeColors.slateGreen200.color,
          surface: ThemeColors.slateGreen900.color,
          error: ThemeColors.red.color,
          onPrimary: ThemeColors.slateGreen900.color,
          onSecondary: ThemeColors.neutral1.color,
          onSurface: ThemeColors.neutral1.color,
          outline: ThemeColors.neutral4.color,
        ),

        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.25,
          ),
          displaySmall: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            color: ThemeColors.mauve100.color,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: TextStyle(
            color: ThemeColors.mauve100.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            color: ThemeColors.mauve100.color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            color: ThemeColors.neutral2.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            color: ThemeColors.neutral2.color,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            color: ThemeColors.neutral3.color,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
          labelLarge: TextStyle(
            color: ThemeColors.lime200.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: TextStyle(
            color: ThemeColors.slateGreen200.color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          labelSmall: TextStyle(
            color: ThemeColors.neutral3.color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: ThemeColors.mauve300.color),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: ThemeColors.lime500.color.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: ThemeColors.mauve300.color, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ThemeColors.slateGreen900.color.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ThemeColors.lime500.color, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ThemeColors.red.color, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: ThemeColors.red.color, width: 2),
          ),
          labelStyle: TextStyle(
            color: ThemeColors.mauve300.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(color: ThemeColors.neutral3.color, fontSize: 16),
        ),
        iconTheme: IconThemeData(color: ThemeColors.mauve300.color),
        dividerTheme: DividerThemeData(
          color: ThemeColors.neutral4.color.withValues(alpha: 0.3),
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: ThemeColors.slateGreen900.color,
          contentTextStyle: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: ThemeColors.lime500.color,
          linearTrackColor: ThemeColors.neutral4.color.withValues(alpha: 0.3),
          circularTrackColor: ThemeColors.neutral4.color.withValues(alpha: 0.3),
        ),
      ),
      
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LandingScreen(),
        );
      },
    
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}