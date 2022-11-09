import 'package:leggo/model/geometry.dart';

class GooglePlace {
  final Geometry geometry;
  final String name;
  final String formattedAddress;
  final List<dynamic> addressComponents;
  final String formattedPhoneNumber;
  final String placeId;
  final double rating;
  final List<String> types;
  final String icon;
  final List<String> weekDayText;
  final String website;
  final String url;
  final List<dynamic>? photos;

  GooglePlace({
    required this.geometry,
    required this.placeId,
    required this.weekDayText,
    required this.formattedAddress,
    required this.formattedPhoneNumber,
    required this.name,
    required this.addressComponents,
    required this.rating,
    required this.icon,
    required this.types,
    this.photos,
    required this.url,
    required this.website,
  });

  factory GooglePlace.fromJson(Map<dynamic, dynamic> parsedJson) {
    var typesfromJson = parsedJson['types'];
    List<String> typesList = List<String>.from(typesfromJson);
    return GooglePlace(
        formattedPhoneNumber: parsedJson['formatted_phone_number'],
        formattedAddress: parsedJson['formatted_address'],
        geometry: Geometry.fromJson(parsedJson['geometry']),
        name: parsedJson['name'],
        placeId: parsedJson['place_id'],
        types: typesList,
        icon: parsedJson['icon'],
        rating: parsedJson['rating'],
        addressComponents: List.from(parsedJson['address_components']),
        weekDayText: List.from(parsedJson['opening_hours']['weekday_text']),
        photos: List.from(parsedJson['photos']),
        url: parsedJson['url'],
        website: parsedJson['website']);
  }
}
