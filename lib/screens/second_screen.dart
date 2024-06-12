import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '/db/database_helper.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<List<String>> _coordinates = [];
  List<List<String>> _dbCoordinates = [];

  @override
  void initState() {
    super.initState();
    _loadCoordinates();
    _loadDbCoordinates();
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

  Future<void> _loadDbCoordinates() async {
    List<Map<String, dynamic>> dbCoords = await DatabaseHelper.instance.getCoordinates(); // Corrected
    setState(() {
      _dbCoordinates = dbCoords.map((c) => [
        c['timestamp'].toString(), // Corrected
        c['latitude'].toString(), // Corrected
        c['longitude'].toString() // Corrected
      ]).toList();
    });
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
        title: const Text('Second screen'),
      ),
      body: ListView.builder(
        itemCount: _coordinates.length + _dbCoordinates.length, // Combined count
        itemBuilder: (context, index) {
          if (index < _coordinates.length) {
            var coord = _coordinates[index];
            return ListTile(
              title: Text('CSV Timestamp: ${coord[0]}'),
              subtitle: Text('Latitude: ${coord[1]}, Longitude: ${coord[2]}'),
            );
          } else {
            var dbIndex = index - _coordinates.length;
            var coord = _dbCoordinates[dbIndex];
            return ListTile(
              title: Text('DB Timestamp: ${coord[0]}', style: const TextStyle(color: Colors.blueGrey)),
              subtitle: Text('Latitude: ${coord[1]}, Longitude: ${coord[2]}', style: const TextStyle(color: Colors.blueGrey)),
              onTap: () => _showDeleteDialog(coord[0]), // Passing timestamp to the delete dialog
              onLongPress: () => _showUpdateDialog(coord[0], coord[1], coord[2]), // Added onLongPress
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(String timestamp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm delete $timestamp"),
          content: const Text("Do you want to delete this coordinate?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                await DatabaseHelper.instance.deleteCoordinate(timestamp);
                Navigator.of(context).pop();
                _loadDbCoordinatesAndUpdate(); // Reload data and update UI
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(String timestamp, String currentLat, String currentLong) {
    TextEditingController latController = TextEditingController(text: currentLat);
    TextEditingController longController = TextEditingController(text: currentLong);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update coordinates for $timestamp"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: "Latitude"),
              ),
              TextField(
                controller: longController,
                decoration: const InputDecoration(labelText: "Longitude"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Update"),
              onPressed: () async {
                Navigator.of(context).pop();
                await DatabaseHelper.instance.updateCoordinate(timestamp, latController.text, longController.text);
                _loadDbCoordinatesAndUpdate();
              },
            ),
          ],
        );
      },
    );
  }

  void _loadDbCoordinatesAndUpdate() async {
    List<Map<String, dynamic>> dbCoords = await DatabaseHelper.instance.getCoordinates();
    setState(() {
      _dbCoordinates = dbCoords.map((c) => [
        c['timestamp'].toString(),
        c['latitude'].toString(),
        c['longitude'].toString()
      ]).toList();
    });
  }
}
