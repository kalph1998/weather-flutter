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
  late Future<Weather> _weather;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _weather = getWeatherDetails();
  }

  Future<Weather> getWeatherDetails() async {
    try {
      Position userPosition = await WeatherService().determinePosition();
      print('called');
      return await WeatherService()
          .getWeather(lat: userPosition.latitude, long: userPosition.longitude);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      rethrow;
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
      body: FutureBuilder(
          future: _weather,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState != ConnectionState.waiting) {
              return Center(
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
                          snapshot.data!.cityName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    Lottie.asset(
                      getWeatherAnimation(snapshot.data!.mainCondition),
                    ),
                    //temperature
                    Text(
                      '${snapshot.data!.temperature.round()}°C',
                      style: TextStyle(color: Colors.grey[700], fontSize: 30),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('something went wrong'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
