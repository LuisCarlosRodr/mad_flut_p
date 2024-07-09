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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${weatherData['list'][0]['name']}',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Container(
                width: 200,
                height: 200,
                child: Image.network(
                  iconUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Country: ${weatherData['list'][0]['sys']['country']}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Coordinates: ${widget.latitude}, ${widget.longitude}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Feels Like: ${(weatherData['list'][0]['main']['feels_like'] - 273.15).toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Description: ${weatherData['list'][0]['weather'][0]['description']}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Temperature: ${(weatherData['list'][0]['main']['temp'] - 273.15).toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Humidity: ${weatherData['list'][0]['main']['humidity']}%',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Wind Speed: ${weatherData['list'][0]['wind']['speed']} m/s',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Weather Information'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
