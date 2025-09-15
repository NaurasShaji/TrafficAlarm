class RouteData {
  final String origin;
  final String destination;
  final int durationInMinutes;
  final int durationInTrafficMinutes;
  final String trafficCondition;
  final List<RouteStep> steps;
  final String polyline;
  final double distanceInKm;
  final DateTime timestamp;
  final String summary;

  RouteData({
    required this.origin,
    required this.destination,
    required this.durationInMinutes,
    required this.durationInTrafficMinutes,
    required this.trafficCondition,
    required this.steps,
    required this.polyline,
    required this.distanceInKm,
    required this.timestamp,
    required this.summary,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'durationInMinutes': durationInMinutes,
      'durationInTrafficMinutes': durationInTrafficMinutes,
      'trafficCondition': trafficCondition,
      'steps': steps.map((step) => step.toJson()).toList(),
      'polyline': polyline,
      'distanceInKm': distanceInKm,
      'timestamp': timestamp.toIso8601String(),
      'summary': summary,
    };
  }

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      origin: json['origin'],
      destination: json['destination'],
      durationInMinutes: json['durationInMinutes'],
      durationInTrafficMinutes: json['durationInTrafficMinutes'],
      trafficCondition: json['trafficCondition'],
      steps: (json['steps'] as List)
          .map((step) => RouteStep.fromJson(step))
          .toList(),
      polyline: json['polyline'],
      distanceInKm: json['distanceInKm'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      summary: json['summary'],
    );
  }

  bool get hasSignificantTraffic => durationInTrafficMinutes > durationInMinutes * 1.2;

  String get trafficEmoji {
    switch (trafficCondition.toLowerCase()) {
      case 'light':
        return '🟢';
      case 'moderate':
        return '🟡';
      case 'heavy':
        return '🔴';
      default:
        return '⚪';
    }
  }

  String get formattedDuration {
    final hours = durationInTrafficMinutes ~/ 60;
    final minutes = durationInTrafficMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class RouteStep {
  final String instruction;
  final int durationInMinutes;
  final double distanceInKm;
  final String maneuver;
  final String polyline;

  RouteStep({
    required this.instruction,
    required this.durationInMinutes,
    required this.distanceInKm,
    required this.maneuver,
    required this.polyline,
  });

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'durationInMinutes': durationInMinutes,
      'distanceInKm': distanceInKm,
      'maneuver': maneuver,
      'polyline': polyline,
    };
  }

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'],
      durationInMinutes: json['durationInMinutes'],
      distanceInKm: json['distanceInKm'].toDouble(),
      maneuver: json['maneuver'],
      polyline: json['polyline'],
    );
  }
}
