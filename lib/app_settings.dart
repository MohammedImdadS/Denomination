import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  bool isNightMode = false;
  String selectedCurrency = 'Indian';

  // Method to toggle night mode
  void toggleNightMode() {
    isNightMode = !isNightMode;
    notifyListeners(); // Notify listeners of the change
  }

  // Method to set selected currency
  void setSelectedCurrency(String currency) {
    selectedCurrency = currency;
    notifyListeners(); // Notify listeners of the change
  }
}

