import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:location/location.dart';

class LocationWeather {
  LocationWeather({this.apiKey}) {
    _location = new Location();
  }
  Map<String, double> currentLocation = <String, double>{};
  bool obtainingLocation = false;
  bool obtainingWeather = false;
  final String apiKey;
  DateTime lastUpdate;
  Location _location;

  bool isReady() {
    return !obtainingWeather && !obtainingLocation;
  }
  Future refresh(Map<String, dynamic> weatherInfo) async {
    if (apiKey.trim().length==0) {
      return;
    }
    try {
      DateTime now = DateTime.now();
      if (lastUpdate == null || now.difference(lastUpdate).inMinutes > 5) {
        obtainingLocation = true;

        this.currentLocation = await _location.getLocation;
        weatherInfo['latlon'] = "${currentLocation['latitude']}, ${currentLocation['longitude']}";
        obtainingLocation = false;
        lastUpdate = now;
      }
      await obtainWeatherData(weatherInfo);
    } catch(e) {
      print(e.toString());
    }
  }

  Future obtainWeatherData(Map<String, dynamic> weatherInfo) async {
    obtainingWeather = true;
    final Response weatherResponse = await get("http://api.openweathermap.org/data/2.5/weather?lat=${currentLocation['latitude']}&lon=${currentLocation['longitude']}&appid=$apiKey");
    final jsonBody = json.decode(weatherResponse.body);
    //obtain the temperature.
    var weatherData = jsonBody['weather'];
    var temperatureData = jsonBody['main'];
    weatherInfo['weatherStatus'] = weatherData[0]['description'].toString();
    weatherInfo['icon'] = "http://openweathermap.org/img/w/${weatherData[0]['icon'].toString()}.png";
    weatherInfo['temperature'] = "${kToC(temperatureData['temp']).toStringAsFixed(2)} C";
    obtainingWeather = false;
  }

  double kToC(double input) {
    return input - 273.15;
  }
}