import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/history_controller.dart';
import 'logic/meal_controller.dart';
import 'logic/storage.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Necesario antes de usar plugins (shared_preferences) en main().
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await Storage.open();

  runApp(
    // MultiProvider pone los controladores "encima" de toda la app para que
    // cualquier pantalla pueda leerlos con context.watch / context.read.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MealController(storage)),
        ChangeNotifierProvider(create: (_) => HistoryController(storage)),
      ],
      child: const ZakeApp(),
    ),
  );
}

class ZakeApp extends StatelessWidget {
  const ZakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zake Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
