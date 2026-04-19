class CheckIn {
  final String qrData;
  final double lat;
  final double lng;
  final DateTime timestamp;

  CheckIn({
    required this.qrData,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) => CheckIn(
    qrData: json['qrData'],
    lat: json['lat'],
    lng: json['lng'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  Map<String, dynamic> toJson() => {
    'qrData': qrData,
    'lat': lat,
    'lng': lng,
    'timestamp': timestamp.toIso8601String(),
  };
}
