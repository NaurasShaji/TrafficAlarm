class AlarmSettings {
  final String destination;
  final DateTime arrivalTime;
  final int bufferMinutes;
  final DateTime? calculatedAlarmTime;
  final bool isActive;
  final String id;

  AlarmSettings({
    required this.destination,
    required this.arrivalTime,
    required this.bufferMinutes,
    this.calculatedAlarmTime,
    this.isActive = false,
    required this.id,
  });

  AlarmSettings copyWith({
    String? destination,
    DateTime? arrivalTime,
    int? bufferMinutes,
    DateTime? calculatedAlarmTime,
    bool? isActive,
    String? id,
  }) {
    return AlarmSettings(
      destination: destination ?? this.destination,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      bufferMinutes: bufferMinutes ?? this.bufferMinutes,
      calculatedAlarmTime: calculatedAlarmTime ?? this.calculatedAlarmTime,
      isActive: isActive ?? this.isActive,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'arrivalTime': arrivalTime.toIso8601String(),
      'bufferMinutes': bufferMinutes,
      'calculatedAlarmTime': calculatedAlarmTime?.toIso8601String(),
      'isActive': isActive,
      'id': id,
    };
  }

  factory AlarmSettings.fromJson(Map<String, dynamic> json) {
    return AlarmSettings(
      destination: json['destination'],
      arrivalTime: DateTime.parse(json['arrivalTime']),
      bufferMinutes: json['bufferMinutes'],
      calculatedAlarmTime: json['calculatedAlarmTime'] != null
          ? DateTime.parse(json['calculatedAlarmTime'])
          : null,
      isActive: json['isActive'] ?? false,
      id: json['id'],
    );
  }
}
