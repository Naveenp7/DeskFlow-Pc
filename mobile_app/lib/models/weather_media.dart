import 'package:flutter/material.dart';

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
}

class WeatherData {
  final String city;
  final int temp;
  final String condition;
  final int maxTemp;
  final int minTemp;
  final int feelsLike;
  final List<ForecastDay> forecast;

  const WeatherData({
    required this.city,
    required this.temp,
    required this.condition,
    required this.maxTemp,
    required this.minTemp,
    required this.feelsLike,
    required this.forecast,
  });

  static WeatherData mock() {
    return const WeatherData(
      city: 'Tallinn',
      temp: 6,
      condition: 'Overcast',
      maxTemp: 6,
      minTemp: 3,
      feelsLike: 2,
      forecast: [
        ForecastDay(
          day: 'Today',
          icon: Icons.grain_rounded,
          maxTemp: 6,
          minTemp: 3,
          rainPct: 100,
        ),
        ForecastDay(
          day: 'Wed',
          icon: Icons.cloud_rounded,
          maxTemp: 6,
          minTemp: 4,
          rainPct: 54,
        ),
        ForecastDay(
          day: 'Thu',
          icon: Icons.wb_sunny_rounded,
          maxTemp: 4,
          minTemp: 3,
          rainPct: 54,
        ),
        ForecastDay(
          day: 'Fri',
          icon: Icons.thunderstorm_rounded,
          maxTemp: 6,
          minTemp: 3,
          rainPct: 55,
        ),
      ],
    );
  }
}

class MediaTrackInfo {
  final String title;
  final String artist;
  final String source;
  final int currentSeconds;
  final int totalSeconds;
  final bool isPlaying;
  final int volume;

  const MediaTrackInfo({
    required this.title,
    required this.artist,
    required this.source,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.isPlaying,
    required this.volume,
  });

  String get positionStr {
    final m = currentSeconds ~/ 60;
    final s = (currentSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get totalStr {
    final m = totalSeconds ~/ 60;
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static MediaTrackInfo mock() {
    return const MediaTrackInfo(
      title: 'Midnight Circuit',
      artist: 'Neon Harbor · Low Tide Lights',
      source: 'SPOTIFY',
      currentSeconds: 160,
      totalSeconds: 214,
      isPlaying: true,
      volume: 42,
    );
  }
}
