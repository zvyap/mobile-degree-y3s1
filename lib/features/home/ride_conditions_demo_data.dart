class RideConditionsDemoData {
  const RideConditionsDemoData({
    required this.location,
    required this.currentCondition,
    required this.currentTemperature,
    required this.feelsLike,
    required this.nextHourCondition,
    required this.nextHourTemperature,
    required this.nextHourRainChance,
    required this.humidity,
    required this.airQualityIndex,
    required this.airQualityLabel,
    required this.wind,
    required this.updatedTime,
    required this.date,
  });

  final String location;
  final String currentCondition;
  final String currentTemperature;
  final String feelsLike;
  final String nextHourCondition;
  final String nextHourTemperature;
  final String nextHourRainChance;
  final String humidity;
  final String airQualityIndex;
  final String airQualityLabel;
  final String wind;
  final String updatedTime;
  final DateTime date;

  // TODO: Replace this prototype data with cached weather data from
  // api.met.gov.my and resolve the user's coordinates into a detailed
  // current-location label.
  // Forecast fields returned by the API are in Bahasa Melayu.
  // Translate documented BM forecast values into English before display.
  static RideConditionsDemoData current({DateTime? date}) {
    return RideConditionsDemoData(
      location: 'Jalan Sultan Ismail, Bukit Bintang, Kuala Lumpur',
      currentCondition: 'Partly cloudy',
      currentTemperature: '30°C',
      feelsLike: 'Feels like 34°C',
      nextHourCondition: 'Scattered thunderstorms',
      nextHourTemperature: '29°C',
      nextHourRainChance: '65% rain',
      humidity: '78%',
      airQualityIndex: '42',
      airQualityLabel: 'Good',
      wind: '9 km/h SW',
      updatedTime: '10:30 AM',
      date: date ?? DateTime.now(),
    );
  }

  static const plannedBmToEnglishForecasts = <String, String>{
    'Tiada hujan': 'No rain',
    'Hujan': 'Rain',
    'Hujan di beberapa tempat': 'Scattered rain',
    'Ribut petir': 'Thunderstorms',
    'Ribut petir di beberapa tempat': 'Scattered thunderstorms',
    'Berjerebu': 'Hazy',
  };
  // TODO: When API wiring is added, display the original Bahasa Melayu value
  // whenever a forecast is not present in the translation map above.

  String get dateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
