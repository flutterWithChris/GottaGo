class ViewportResult {
  final double northEastLat, northEastLng, southWestLat, southWestLng;

  ViewportResult(
      {required this.northEastLat,
      required this.northEastLng,
      required this.southWestLat,
      required this.southWestLng});

  factory ViewportResult.fromJson(Map<dynamic, dynamic> parsedJson) {
    return ViewportResult(
      northEastLat: parsedJson['northeast']['lat'],
      northEastLng: parsedJson['northeast']['lng'],
      southWestLat: parsedJson['southwest']['lat'],
      southWestLng: parsedJson['southwest']['lng'],
    );
  }
}
