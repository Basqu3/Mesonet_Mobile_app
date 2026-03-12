import 'package:app_001/Screens/HomeManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color _logoBlue = Color(0xFF0073A2);
const Color _logoBlueLight = Color(0xFF8FD1E9);
const Color _accentGreen = Color(0xFF2E7D62);
const Color _lightSurface = Color(0xFFF5F7FA);
const Color _lightSurfaceContainer = Color(0xFFE7EDF3);
const Color _darkSurface = Color(0xFF0F1720);
const Color _darkSurfaceContainer = Color(0xFF1B2733);
const Color _darkOnSurface = Color(0xFFE6EDF5);
const Color _lightOnSurface = Color(0xFF14202B);

void main() {
  runApp(const MainApp());
}

@pragma('vm:entry-point')
Future<String> apiCall(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  final ColorScheme base = ColorScheme.fromSeed(
    seedColor: _logoBlue,
    brightness: brightness,
  );

  final ColorScheme scheme = base.copyWith(
    primary: _logoBlue,
    onPrimary: Colors.white,
    primaryContainer: isDark ? const Color(0xFF0F3D57) : _logoBlueLight,
    onPrimaryContainer: isDark ? _darkOnSurface : _lightOnSurface,
    secondary: isDark ? const Color(0xFF4EA58A) : _accentGreen,
    onSecondary: Colors.white,
    secondaryContainer:
        isDark ? const Color(0xFF173B30) : const Color(0xFFBFE2D5),
    onSecondaryContainer: isDark ? _darkOnSurface : _lightOnSurface,
    tertiary: isDark ? _darkSurfaceContainer : _lightSurfaceContainer,
    onTertiary: isDark ? const Color(0xFFB7C6D6) : const Color(0xFF4D6072),
    surface: isDark ? _darkSurface : _lightSurface,
    onSurface: isDark ? _darkOnSurface : _lightOnSurface,
    error: const Color(0xFFB42318),
    onError: Colors.white,
    outline: isDark ? const Color(0xFF415466) : const Color(0xFF7A8A99),
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: isDark ? scheme.tertiary : Colors.white,
      elevation: 1,
      margin: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? scheme.tertiary : const Color(0xFF1F2933),
      contentTextStyle: TextStyle(
        color: isDark ? scheme.onSurface : Colors.white,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: scheme.primaryContainer,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: scheme.primary,
      selectedItemColor: scheme.onPrimary,
      unselectedItemColor: scheme.primaryContainer,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 14,
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Montana Climate Office',
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const HomeManager(),
    );
  }
}
