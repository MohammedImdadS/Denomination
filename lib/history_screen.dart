import 'dart:convert';
import 'package:countcash/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:number_to_text_converter/number_to_text_converter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

// Create a logger instance
final logger = Logger();

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getSavedData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              logger.e('Error loading data: ${snapshot.error}');
              return const Center(child: Text('Error loading data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No saved data yet'));
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = snapshot.data![index];
                DateTime dateTime = DateTime.parse(data['dateTime']);
                String formattedDateTime =
                    DateFormat('EEE, MMM d, y, h:mm a').format(dateTime);
                return ListTile(
                  title: Text(data['name']),
                  subtitle: Text(
                    'Total Amount: ₹${data['totalAmount']}\n $formattedDateTime',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashCardScreen(data: data),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          _shareData(data);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteData(data);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs.getKeys().toList();
    List<Map<String, dynamic>> dataList = [];
    try {
      for (String key in keys) {
        String? jsonData = prefs.getString(key);
        if (jsonData != null) {
          try {
            // Convert the JSON string back to Map
            Map<String, dynamic> data = json.decode(jsonData);
            // Retrieve the denominations map directly
            Map<String, dynamic> denominations =
                Map<String, dynamic>.from(data['denominations']);
            data['denominations'] = denominations;
            dataList.add(data);
          } catch (e) {
            logger.e('Error decoding JSON for key: $key');
            logger.e('JSON data: $jsonData');
            logger.e('Error details: $e');
          }
        }
      }
    } catch (e) {
      logger.e('Error loading data: $e');
    }
    if (dataList.isEmpty) {
      logger.d('No saved data yet');
    }
    return dataList;
  }

  void _shareData(Map<String, dynamic> data) {
    String name = data['name'];
    String totalAmount = data['totalAmount'].toString();
    String totalAmountInWords = AppSettings().selectedCurrency == 'Indian'
        ? NumberToTextConverter.forIndianNumberingSystem()
            .convert(data['totalAmount'])
        : NumberToTextConverter.forInternationalNumberingSystem()
            .convert(data['totalAmount']);
    String denominations = '';
    for (String denomination in data['denominations'].keys) {
      int multiplier = data['denominations'][denomination];
      int amount = int.parse(denomination.replaceAll('₹', ''));
      denominations +=
          '$denomination x $multiplier = ₹${amount * multiplier}\n';
    }
    String shareText =
        'Name: $name\nTotal Amount: ₹$totalAmount\nTotal Amount in Words: $totalAmountInWords\nDenominations:\n$denominations';
    Share.share(shareText);
  }

  void _deleteData(Map<String, dynamic> data) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Data'),
          content: const Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String key = data['dateTime'];
      await prefs.remove(key);
      setState(() {});
    }
  }
}

class FlashCardScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const FlashCardScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(data['name']),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                _shareData(data);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount: ₹${data['totalAmount']}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    settings.selectedCurrency == 'Indian'
                        ? NumberToTextConverter.forIndianNumberingSystem()
                            .convert(data['totalAmount'])
                        : NumberToTextConverter
                                .forInternationalNumberingSystem()
                            .convert(data['totalAmount']),
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Denominations:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data['denominations'].length,
                    itemBuilder: (context, index) {
                      String denomination =
                          data['denominations'].keys.elementAt(index);
                      int multiplier =
                          data['denominations'].values.elementAt(index);
                      int amount = int.parse(denomination.replaceAll('₹', ''));
                      return ListTile(
                        title: Row(
                          children: [
                            Text("$denomination x $multiplier"),
                            const SizedBox(width: 10),
                            Text('= ₹${amount * multiplier}'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _shareData(Map<String, dynamic> data) {
    String name = data['name'];
    String totalAmount = data['totalAmount'].toString();
    String totalAmountInWords = AppSettings().selectedCurrency == 'Indian'
        ? NumberToTextConverter.forIndianNumberingSystem()
            .convert(data['totalAmount'])
        : NumberToTextConverter.forInternationalNumberingSystem()
            .convert(data['totalAmount']);
    String denominations = '';
    for (String denomination in data['denominations'].keys) {
      int multiplier = data['denominations'][denomination];
      int amount = int.parse(denomination.replaceAll('₹', ''));
      denominations +=
          '$denomination x $multiplier = ₹${amount * multiplier}\n';
    }
    String shareText =
        'Name: $name\nTotal Amount: ₹$totalAmount\nTotal Amount in Words: $totalAmountInWords\nDenominations:\n$denominations';
    Share.share(shareText);
  }
}
