import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mad_flut_p/screens/weather_screen.dart';
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
    List<Map<String, dynamic>> dbCoords = await DatabaseHelper.instance.getCoordinates();
    setState(() {
      _dbCoordinates = dbCoords.map((c) => [
        c['timestamp'].toString(),
        c['latitude'].toString(),
        c['longitude'].toString()
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
        title: const Text('Coordinates Information'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _coordinates.length + _dbCoordinates.length,
          itemBuilder: (context, index) {
            if (index < _coordinates.length) {
              var coord = _coordinates[index];
              return _buildCard(
                title: 'CSV Timestamp: ${coord[0]}',
                subtitle: 'Latitude: ${coord[1]}, Longitude: ${coord[2]}',
                icon: Icons.location_on,
                color: Colors.lightBlue[100]!,
              );
            } else {
              var dbIndex = index - _coordinates.length;
              var coord = _dbCoordinates[dbIndex];
              return _buildCard(
                title: 'DB Timestamp: ${coord[0]}',
                subtitle: 'Latitude: ${coord[1]}, Longitude: ${coord[2]}',
                icon: Icons.storage,
                color: Colors.lightGreen[100]!,
                onTap: () => _showDeleteDialog(coord[0]),
                onLongPress: () => _showUpdateDialog(coord[0], coord[1], coord[2]),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    void Function()? onTap,
    void Function()? onLongPress,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.blueGrey[700]),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  void _showDeleteDialog(String timestamp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Delete",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          content: Text(
            "Do you want to delete the coordinate for $timestamp?",
            style: TextStyle(color: Colors.blueGrey[600]),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blueGrey[800]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Delete"),
              onPressed: () async {
                await DatabaseHelper.instance.deleteCoordinate(timestamp);
                Navigator.of(context).pop();
                _loadDbCoordinatesAndUpdate();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
          title: Text(
            "Update Coordinates",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Timestamp: $timestamp",
                    style: TextStyle(color: Colors.blueGrey[600]),
                  ),
                ),
                TextField(
                  controller: latController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.my_location, color: Colors.blueGrey[800]),
                    labelText: "Latitude",
                    labelStyle: TextStyle(color: Colors.blueGrey[600]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[300]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[800]!),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: longController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_on, color: Colors.blueGrey[800]),
                    labelText: "Longitude",
                    labelStyle: TextStyle(color: Colors.blueGrey[600]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[300]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey[800]!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blueGrey[800]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Update"),
              onPressed: () async {
                Navigator.of(context).pop();
                await DatabaseHelper.instance.updateCoordinate(timestamp, latController.text, longController.text);
                _loadDbCoordinatesAndUpdate();
              },
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blueGrey[800]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Weather Info"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherScreen(
                      latitude: latController.text,
                      longitude: longController.text,
                    ),
                  ),
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

// WeatherScreen widget would be implemented elsewhere in your codebase


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

