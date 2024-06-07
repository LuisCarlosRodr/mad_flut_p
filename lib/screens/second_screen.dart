import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<List<String>> _coordinates = [];

  @override
  void initState() {
    super.initState();
    _loadCoordinates();
    print("initState: Initial state setup.");
  }

  Future<void> _loadCoordinates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gps_coordinates.csv');
      List<String> lines = await file.readAsLines();
      setState(() {
        _coordinates = lines.map((line) => line.split(';')).toList();
      });
    } catch (e) {
      print("Error loading coordinates: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies: Dependencies updated.");
  }

  @override
  void didUpdateWidget(SecondScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget: The widget has been updated from the parent.");
  }

  @override
  void dispose() {
    print("dispose: Cleaning up before the state is destroyed.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build: Building the user interface.");
    return Scaffold(
      appBar: AppBar(
        title: Text('Second screen'),
      ),
      body: ListView.builder(
        itemCount: _coordinates.length,
        itemBuilder: (context, index) {
          var coord = _coordinates[index];
          var formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss')
              .format(DateTime.fromMillisecondsSinceEpoch(int.parse(coord[0])));
          return ListTile(
            title: Text('Timestamp: $formattedDate'),
            subtitle: Text('Latitude: ${coord[1]}, Longitude: ${coord[2]}'),
          );
        },
      ),
    );
  }
}
