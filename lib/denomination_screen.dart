import 'package:countcash/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_to_text_converter/number_to_text_converter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DenominationScreen extends StatefulWidget {
  const DenominationScreen({Key? key}) : super(key: key);
  @override
  State<DenominationScreen> createState() => _DenominationScreenState();
}

class _DenominationScreenState extends State<DenominationScreen> {
  final _nameController = TextEditingController();
  final List<TextEditingController> _multiplierControllers = List.generate(
    8,
    (index) => TextEditingController(),
  );

  // Fixed currency values
  final List<int> currencyValues = [2000, 1000, 500, 200, 100, 50, 20, 10];

  // Multipliers for each currency value
  List<int> multipliers = List.filled(8, 0);

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 0) {
      _showHome();
    } else if (index == 1) {
      _saveCalculations();
    } else if (index == 2) {
      _showHistory();
    } else if (index == 3) {
      _showSetting();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateMultipliers(int index, int value) {
    setState(() {
      multipliers[index] = value;
    });
  }

  void _showHistory() async {
    Navigator.pushNamed(context, '/history');
  }

  void _showHome() async {
    Navigator.pushNamed(context, '/home');
  }

  void _showSetting() async {
    Navigator.pushNamed(context, '/settings');
  }

  void _saveCalculations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = _nameController.text;
    int totalAmount = 0;
    for (int i = 0; i < currencyValues.length; i++) {
      totalAmount += currencyValues[i] * multipliers[i];
    }

    // Check if multiplier values are empty or all zero
    if (!multipliers.any((multiplier) => multiplier != 0)) {
      showSaveDialog('Invalid Input', 'Please enter valid multiplier values.');
      return;
    }

    DateTime now = DateTime.now();
    Map<String, int> denominations = {};
    for (int i = 0; i < currencyValues.length; i++) {
      denominations['₹${currencyValues[i]}'] = multipliers[i];
    }

    // Generate a unique key for each set of data
    String key = now.toString();
    Map<String, dynamic> data = {
      'name': name,
      'totalAmount': totalAmount,
      'dateTime': now.toString(),
      'denominations': denominations,
    };

    // Save the data directly without encoding it as JSON
    await prefs.setString(key, json.encode(data));

    showSaveDialog('Data Saved', 'Your data has been successfully saved.');

    _nameController.clear();
    for (var controller in _multiplierControllers) {
      controller.clear();
    }
    setState(() {
      totalAmount = 0;
      multipliers = List.filled(8, 0);
    });
  }

  void showSaveDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalAmount = 0;
    for (int i = 0; i < currencyValues.length; i++) {
      totalAmount += currencyValues[i] * multipliers[i];
    }
    final settings = Provider.of<AppSettings>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Denomination App'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12.0),
                    border: OutlineInputBorder(),
                    labelText: 'Enter Denomination Name',
                  ),
                  maxLength: 20,
                ),
                Text(
                  'Total: ₹$totalAmount',
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                Text(
                  settings.selectedCurrency == 'Indian'
                      ? NumberToTextConverter.forIndianNumberingSystem()
                          .convert(totalAmount)
                      : NumberToTextConverter.forInternationalNumberingSystem()
                          .convert(totalAmount),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currencyValues.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            '₹${currencyValues[index]}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: TextFormField(
                            controller: _multiplierControllers[index],
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              _updateMultipliers(
                                  index, int.tryParse(value) ?? 0);
                            },
                            decoration: const InputDecoration(
                              counterText: '',
                              errorMaxLines: 1,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Text(
                            "₹${multipliers[index] * currencyValues[index]}/-",
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
