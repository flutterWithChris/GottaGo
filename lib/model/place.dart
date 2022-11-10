import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String? name;
  final String? placeId;
  final String? address;
  final String? city;
  final String? state;
  final List<dynamic>? reviews;
  final String? mapsUrl;
  final String? phoneNumber;
  final double? rating;
  final String? website;
  final String? icon;
  final String? type;
  final String? mainPhoto;
  final List<dynamic>? hours;

  Place({
    required this.placeId,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.phoneNumber,
    required this.icon,
    this.reviews,
    this.rating,
    this.website,
    required this.type,
    required this.mapsUrl,
    required this.mainPhoto,
    this.hours,
  });

  Place copyWith({
    String? placeId,
    String? name,
    String? address,
    String? city,
    String? state,
    List<dynamic>? reviews,
    double? rating,
    String? website,
    String? type,
    String? mainPhoto,
    String? phoneNumber,
    String? icon,
    String? mapsUrl,
    List<dynamic>? hours,
  }) {
    return Place(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      reviews: reviews ?? this.reviews,
      rating: rating ?? this.rating,
      website: website ?? this.website,
      type: type ?? this.type,
      mainPhoto: mainPhoto ?? this.mainPhoto,
      hours: hours ?? this.hours,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      icon: icon ?? this.icon,
      mapsUrl: mapsUrl ?? this.mapsUrl,
    );
  }

  factory Place.fromSnapshot(DocumentSnapshot snap) {
    return Place(
      placeId: snap['placeId'],
      state: snap['state'],
      name: snap.id,
      address: snap['address'],
      city: snap['city'],
      reviews: snap['reviews']!,
      rating: snap['rating'],
      website: snap['website'],
      type: snap['type'],
      mainPhoto: snap['mainPhoto'],
      hours: snap['hours'],
      mapsUrl: snap['mapsUrl'],
      phoneNumber: snap['phoneNumber'],
      icon: snap['icon'],
    );
  }

  Map<String, Object> toDocument() {
    return {
      'placeId': placeId ?? placeId!,
      'name': name ?? name!,
      'address': address ?? address!,
      'city': city ?? city!,
      'state': state ?? state!,
      'reviews': reviews ?? reviews!,
      'rating': rating ?? rating!,
      'website': website ?? website!,
      'type': type ?? type!,
      'mainPhoto': mainPhoto ?? mainPhoto!,
      'hours': hours ?? hours!,
      'mapsUrl': mapsUrl ?? mapsUrl!,
      'phoneNumber': phoneNumber ?? phoneNumber!,
      'icon': icon ?? icon!,
    };
  }
}
