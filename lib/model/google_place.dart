import 'package:leggo/model/geometry.dart';

class GooglePlace {
  final Geometry geometry;
  final String name;
  final List<String> types;

  GooglePlace(
      {required this.geometry, required this.name, required this.types});

  factory GooglePlace.fromJson(Map<dynamic, dynamic> parsedJson) {
    var typesfromJson = parsedJson['types'];
    List<String> typesList = List<String>.from(typesfromJson);
    return GooglePlace(
      geometry: Geometry.fromJson(parsedJson['geometry']),
      name: parsedJson['formatted_address'],
      types: typesList,
    );
  }
}
