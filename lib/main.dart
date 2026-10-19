import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/task_store.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await NotificationService.init();
  await TaskStore.init();

  runApp(const QuwatAlaanApp());
}

class QuwatAlaanApp extends StatelessWidget {
  const QuwatAlaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قوة الآن 💪',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF388E3C),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}