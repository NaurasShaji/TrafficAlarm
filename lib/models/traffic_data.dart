class TrafficData {
  final String origin;
  final String destination;
  final int durationInMinutes;
  final int durationInTrafficMinutes;
  final String trafficCondition; // 'light', 'moderate', 'heavy'
  final DateTime timestamp;

  TrafficData({
    required this.origin,
    required this.destination,
    required this.durationInMinutes,
    required this.durationInTrafficMinutes,
    required this.trafficCondition,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'durationInMinutes': durationInMinutes,
      'durationInTrafficMinutes': durationInTrafficMinutes,
      'trafficCondition': trafficCondition,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TrafficData.fromJson(Map<String, dynamic> json) {
    return TrafficData(
      origin: json['origin'],
      destination: json['destination'],
      durationInMinutes: json['durationInMinutes'],
      durationInTrafficMinutes: json['durationInTrafficMinutes'],
      trafficCondition: json['trafficCondition'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  bool get hasSignificantTraffic => durationInTrafficMinutes > durationInMinutes * 1.2;
}
