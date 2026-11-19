import 'package:flutter/material.dart';

const Map<String, IconData> _weatherIcons = {
  'sunny': Icons.wb_sunny_rounded,
  'cloudy': Icons.cloud_rounded,
  'fog': Icons.foggy,
  'rain': Icons.grain_rounded,
  'snow': Icons.ac_unit_rounded,
  'storm': Icons.thunderstorm_rounded,
};

IconData weatherIconFor(String condition) =>
    _weatherIcons[condition] ?? Icons.cloud_rounded;

class ForecastDay {
  final String day;
  final IconData icon;
  final int maxTemp;
  final int minTemp;
  final int rainPct;

  const ForecastDay({
    required this.day,
    required this.icon,
    required this.maxTemp,
    required this.minTemp,
    required this.rainPct,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      day: json['day'] as String? ?? '',
      icon: weatherIconFor(json['icon'] as String? ?? 'cloudy'),
      maxTemp: (json['max_temp'] as num?)?.round() ?? 0,
      minTemp: (json['min_temp'] as num?)?.round() ?? 0,
      rainPct: (json['rain_pct'] as num?)?.round() ?? 0,
    );
  }
}

class WeatherData {
  final bool available;
  final String city;
  final int temp;
  final String condition;
  final int maxTemp;
  final int minTemp;
  final int feelsLike;
  final List<ForecastDay> forecast;

  const WeatherData({
    required this.available,
    required this.city,
    required this.temp,
    required this.condition,
    required this.maxTemp,
    required this.minTemp,
    required this.feelsLike,
    required this.forecast,
  });

  factory WeatherData.initial() {
    return const WeatherData(
      available: false,
      city: '',
      temp: 0,
      condition: 'cloudy',
      maxTemp: 0,
      minTemp: 0,
      feelsLike: 0,
      forecast: [],
    );
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    if (json['available'] != true) return WeatherData.initial();
    final forecastJson = json['forecast'] as List<dynamic>? ?? const [];
    return WeatherData(
      available: true,
      city: json['city'] as String? ?? 'Current location',
      temp: (json['temp'] as num?)?.round() ?? 0,
      condition: json['condition'] as String? ?? 'cloudy',
      maxTemp: (json['max_temp'] as num?)?.round() ?? 0,
      minTemp: (json['min_temp'] as num?)?.round() ?? 0,
      feelsLike: (json['feels_like'] as num?)?.round() ?? 0,
      forecast: forecastJson
          .whereType<Map<String, dynamic>>()
          .map((d) => ForecastDay.fromJson(d))
          .toList(),
    );
  }
}
