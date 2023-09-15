import 'package:countcash/app_settings.dart';
import 'package:countcash/denamination_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const DenominationApp(),
    ),
  );
}




