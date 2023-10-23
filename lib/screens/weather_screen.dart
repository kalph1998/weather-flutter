import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/models/weather_model.dart';
import 'package:weather/service/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Weather? _weather;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWeatherDetails();
  }

  getWeatherDetails() async {
    try {
      Position userPosition = await WeatherService().determinePosition();
      Weather weather = await WeatherService()
          .getWeather(lat: userPosition.latitude, long: userPosition.longitude);
      setState(() {
        _weather = weather;
      });
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/animation/sunny.json';

    switch (mainCondition) {
      case 'Clouds':
        return 'assets/animation/cloudy.json';
      case 'Clear':
        return 'assets/animation/sunny.json';
      case 'Rain':
        return 'assets/animation/rain.json';
      default:
        return 'assets/animation/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //city name
              Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _weather?.cityName.toUpperCase() ?? 'City name',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              Lottie.asset(
                getWeatherAnimation(_weather?.mainCondition),
              ),
              //temperature
              Text(
                '${_weather?.temperature.round()}°C',
                style: TextStyle(color: Colors.grey[700], fontSize: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
