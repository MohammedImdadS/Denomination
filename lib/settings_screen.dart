import 'package:countcash/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async{
        Navigator.pushNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Consumer<AppSettings>(
                builder: (context, settings, child) {
                  return SwitchListTile(
                    title: const Text('Night Mode'),
                    value: settings.isNightMode,
                    onChanged: (value) {
                      settings.toggleNightMode(); // Toggle night mode
                    },
                  );
                },
              ),
              const Divider(),
              Consumer<AppSettings>(
                builder: (context, settings, child) {
                  return ListTile(
                    title: const Text('Currency'),
                    subtitle: DropdownButton<String>(
                      value: settings.selectedCurrency,
                      onChanged: (String? newValue) {
                        settings.setSelectedCurrency(
                            newValue!); // Set selected currency
                      },
                      items: <String>['Indian', 'International']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
