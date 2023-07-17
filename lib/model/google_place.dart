import 'package:leggo/model/geometry.dart';

class GooglePlace {
  final Geometry? geometry;
  final String? name;
  final String? formattedAddress;
  final List<dynamic>? addressComponents;
  final String? formattedPhoneNumber;
  final String? placeId;
  final double? rating;
  final String? type;
  final String? icon;
  final List<String>? weekDayText;
  final String? website;
  final String? url;
  final List<dynamic>? reviews;
  final List<dynamic>? photos;

  GooglePlace({
    this.geometry,
    this.placeId,
    this.weekDayText,
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.name,
    this.addressComponents,
    this.rating,
    this.icon,
    this.type,
    this.reviews,
    this.photos,
    this.url,
    this.website,
  });

  factory GooglePlace.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GooglePlace(
        formattedPhoneNumber: parsedJson['formatted_phone_number'],
        formattedAddress: parsedJson['vicinity'],
        geometry: Geometry.fromJson(parsedJson['geometry']),
        name: parsedJson['name'],
        placeId: parsedJson['place_id'],
        type: List.from(parsedJson['types']).first,
        icon: parsedJson['icon'],
        rating: parsedJson['rating'],
        addressComponents: List.from(parsedJson['address_components']),
        // Add null check for weekday_text
        weekDayText: parsedJson['opening_hours'] != null
            ? List.from(parsedJson['opening_hours']['weekday_text'])
            : null,
        photos: List.from(parsedJson['photos']),
        url: parsedJson['url'],
        reviews: parsedJson['reviews'] != null
            ? List.from(parsedJson['reviews'])
            : null,
        website: parsedJson['website']);
  }
}
