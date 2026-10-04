import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import '../features/shell/presentation/app_shell.dart';

class NullSoundApp extends StatelessWidget {
  const NullSoundApp({super.key});
  @override
  Widget build(BuildContext context) => DynamicColorBuilder(
    builder: (lightDynamic, darkDynamic) {
      const seed = Color(0xffbd829f);
      final dark = darkDynamic ?? ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
      final light = lightDynamic ?? ColorScheme.fromSeed(seedColor: seed);
      return MaterialApp(
        title: 'NullSound',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData(colorScheme: light, useMaterial3: true),
        darkTheme: ThemeData(
          colorScheme: dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xff171316),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent, elevation: 0),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: dark.primary.withValues(alpha: .28),
            labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        home: const AppShell(),
      );
    },
  );
}
