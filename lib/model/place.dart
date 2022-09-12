import 'package:flutter/foundation.dart';

class Place {
  final String name;
  final String address;
  final String city;
  final int? rating;
  final String? website;
  final String type;
  final Uint8List mainPhoto;
  Place({
    required this.name,
    required this.address,
    required this.city,
    this.rating,
    this.website,
    required this.type,
    required this.mainPhoto,
  });
}
