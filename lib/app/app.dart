import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import '../features/shell/presentation/app_shell.dart';

class NullSoundApp extends StatelessWidget {
  const NullSoundApp({super.key});
  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
    builder: (lightDynamic, darkDynamic) {
      final seed = lightDynamic?.primary ?? const Color(0xff6750a4);
      return MaterialApp(
        title: 'NullSound',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: seed), useMaterial3: true),
        darkTheme: ThemeData(colorScheme: darkDynamic ?? ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark), useMaterial3: true),
        home: const AppShell(),
      );
    },
  );
}
