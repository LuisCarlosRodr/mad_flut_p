import 'package:flutter/foundation.dart';

class WeatherModel with ChangeNotifier {
  Map<String, dynamic> _weatherData = {};

  Map<String, dynamic> get weatherData => _weatherData;

  void setWeatherData(Map<String, dynamic> newWeatherData) {
    _weatherData = newWeatherData;
    notifyListeners();
  }
}
