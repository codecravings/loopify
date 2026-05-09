import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'services/hive_service.dart';
import 'services/widget_service.dart';
import 'services/midnight_service.dart';
import 'services/notification_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize timezone database for scheduled notifications
    tz.initializeTimeZones();

    // Try to get local timezone, fallback to UTC if fails
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // India timezone
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }
  } catch (e) {
    print('Timezone initialization error: $e');
  }

  await HiveService.init();
  await WidgetService.initWidget();

  // Initialize notification service
  try {
    await NotificationService.initialize();

    // Schedule notifications if enabled
    final userPrefs = HiveService.getUserPrefs();
    if (userPrefs.notificationsEnabled) {
      await NotificationService.scheduleEveningReminder(
        hour: userPrefs.reminderHour,
        minute: userPrefs.reminderMinute,
      );
      await NotificationService.scheduleMidnightCheck();
    }
  } catch (e) {
    print('Notification initialization error: $e');
  }

  // Initialize midnight monitoring service
  MidnightService.initialize();

  runApp(const ProviderScope(child: LoopifyApp()));
}

class LoopifyApp extends StatelessWidget {
  const LoopifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loopify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF0A0E21), // Deep dark blue-black
        cardColor: const Color(0xFF1D1E33), // Dark card background
        canvasColor: const Color(0xFF1D1E33),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.deepOrange,
          surface: const Color(0xFF1D1E33),
          background: const Color(0xFF0A0E21),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
