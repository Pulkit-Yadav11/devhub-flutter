import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final isDark = await StorageService.loadDarkMode();
  runApp(DevHubApp(isDark: isDark));
}

class DevHubApp extends StatefulWidget {
  final bool isDark;
  const DevHubApp({super.key, required this.isDark});

  static _DevHubAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_DevHubAppState>()!;

  @override
  State<DevHubApp> createState() => _DevHubAppState();
}

class _DevHubAppState extends State<DevHubApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  void toggleTheme() {
    setState(() => _isDark = !_isDark);
    StorageService.saveDarkMode(_isDark);
  }

  bool get isDark => _isDark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevHub Showcase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
