import 'package:countcash/app_settings.dart';
import 'package:countcash/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'denomination_screen.dart';
import 'history_screen.dart';

class DenominationApp extends StatelessWidget {
  const DenominationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings =
        Provider.of<AppSettings>(context); // Get the settings from the provider

    return MaterialApp(
      title: 'Denomination App',
      theme: settings.isNightMode
          ? ThemeData.dark()
          : ThemeData(
              primaryColor: Colors.blue,
            ),
      routes: {
        '/home': (context) => const DenominationScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      home: const DenominationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
