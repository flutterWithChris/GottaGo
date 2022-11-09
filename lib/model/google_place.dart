import 'package:leggo/model/geometry.dart';

class GooglePlace {
  final Geometry geometry;
  final String name;
  final String formattedAddress;
  final List<dynamic> addressComponents;
  final String formattedPhoneNumber;
  final String placeId;
  final double rating;
  final String type;
  final String icon;
  final List<String> weekDayText;
  final String website;
  final String url;
  final List<dynamic>? reviews;
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
    required this.type,
    required this.reviews,
    this.photos,
    required this.url,
    required this.website,
  });

  factory GooglePlace.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GooglePlace(
        formattedPhoneNumber: parsedJson['formatted_phone_number'],
        formattedAddress: parsedJson['formatted_address'],
        geometry: Geometry.fromJson(parsedJson['geometry']),
        name: parsedJson['name'],
        placeId: parsedJson['place_id'],
        type: List.from(parsedJson['types']).first,
        icon: parsedJson['icon'],
        rating: parsedJson['rating'],
        addressComponents: List.from(parsedJson['address_components']),
        weekDayText: List.from(parsedJson['opening_hours']['weekday_text']),
        photos: List.from(parsedJson['photos']),
        url: parsedJson['url'],
        reviews: List.from(parsedJson['reviews']),
        website: parsedJson['website']);
  }
}
