import 'dart:convert';
import 'dart:io';

import 'package:weather/key.dart';
import 'package:weather/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const baseURL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey = openWeatherKey;

  Future<Weather> getWeather(
      {required double lat, required double long}) async {
    final url =
        Uri.parse('$baseURL?lat=$lat&lon=$long&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == HttpStatus.ok) {
      final responseJson = json.decode(response.body);
      return Weather.fromJson(responseJson);
    } else {
      throw Exception('some error');
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
