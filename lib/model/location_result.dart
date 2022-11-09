class LocationResult {
  final double lat, lng;

  LocationResult({required this.lat, required this.lng});

  factory LocationResult.fromJson(Map<dynamic, dynamic> parsedJson) {
    return LocationResult(lat: parsedJson['lat'], lng: parsedJson['lng']);
  }
}
