import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/shell/presentation/app_shell.dart';

class NullSoundApp extends StatelessWidget {
  const NullSoundApp({super.key});
  static const accents=[Color(0xffbd829f),Color(0xff8b80d8),Color(0xff5f9fba),Color(0xff68a88d),Color(0xffd49a63),Color(0xffdc7180),Color(0xffe4e4e4)];
  @override Widget build(BuildContext context)=>DynamicColorBuilder(builder:(lightDynamic,darkDynamic)=>FutureBuilder<SharedPreferences>(
    future:SharedPreferences.getInstance(),
    builder:(context,snapshot){
      final prefs=snapshot.data;
      final index=(prefs?.getInt('setting_accent')??0).clamp(0,accents.length-1);
      final seed=accents[index];
      final dark=ColorScheme.fromSeed(seedColor:seed,brightness:Brightness.dark);
      final light=ColorScheme.fromSeed(seedColor:seed,brightness:Brightness.light);
      return MaterialApp(
        title:'NullSound',debugShowCheckedModeBanner:false,themeMode:ThemeMode.dark,
        theme:ThemeData(colorScheme:lightDynamic??light,useMaterial3:true),
        darkTheme:ThemeData(
          colorScheme:darkDynamic??dark,useMaterial3:true,scaffoldBackgroundColor:const Color(0xff171316),
          appBarTheme:const AppBarTheme(backgroundColor:Colors.transparent,surfaceTintColor:Colors.transparent,elevation:0),
          navigationBarTheme:NavigationBarThemeData(backgroundColor:Colors.transparent,indicatorColor:dark.primary.withValues(alpha:.28),labelTextStyle:WidgetStateProperty.all(const TextStyle(fontWeight:FontWeight.w600))),
        ),
        home:const AppShell(),
      );
    }),
  ));
}
