import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../weather_model.dart';

class WeatherScreen extends StatefulWidget {
  final String latitude;
  final String longitude;

  WeatherScreen({required this.latitude, required this.longitude});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late String apiKey = '47c927d9973d9b88170d2e440b1ebaa4';

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/find?lat=${widget.latitude}&lon=${widget.longitude}&cnt=1&APPID=$apiKey',
        ),
      );
      if (response.statusCode == 200) {
        final weatherData = json.decode(response.body);
        Provider.of<WeatherModel>(context, listen: false).setWeatherData(weatherData);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherData = Provider.of<WeatherModel>(context).weatherData;

    if (weatherData.isNotEmpty && weatherData['list'] != null && weatherData['list'].isNotEmpty) {
      String iconCode = weatherData['list'][0]['weather'][0]['icon'];
      String iconUrl = 'http://openweathermap.org/img/wn/$iconCode.png';

      return Scaffold(
        appBar: AppBar(
          title: Text('Weather Information'),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[900]!, Colors.blueGrey[600]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${weatherData['list'][0]['name']}, ${weatherData['list'][0]['sys']['country']}',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.0),
                    Image.network(
                      iconUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildWeatherInfo(
                          'Feels Like',
                          '${(weatherData['list'][0]['main']['feels_like'] - 273.15).toStringAsFixed(1)}°C',
                        ),
                        _buildWeatherInfo(
                          'Temperature',
                          '${(weatherData['list'][0]['main']['temp'] - 273.15).toStringAsFixed(1)}°C',
                        ),
                        _buildWeatherInfo(
                          'Humidity',
                          '${weatherData['list'][0]['main']['humidity']}%',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildWeatherInfo(
                          'Description',
                          '${weatherData['list'][0]['weather'][0]['description']}',
                        ),
                        _buildWeatherInfo(
                          'Wind Speed',
                          '${weatherData['list'][0]['wind']['speed']} m/s',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Weather Information'),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey[900]!, Colors.blueGrey[600]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildWeatherInfo(String title, String value) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.blueGrey[800],
          ),
        ),
      ],
    );
  }
}
