import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'connection_view/view.dart';
import 'styles/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices(); // Initialize all required services
  runApp(const MyApp());
}

Future<void> initServices() async {
  // await DatabaseService().connect();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vertex Stairs',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: DbConnectPage(),
    );
  }
}
