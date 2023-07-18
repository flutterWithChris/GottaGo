import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/google_place.dart';

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
  final List<dynamic>? photos;

  Place({
    this.placeId,
    this.name,
    this.address,
    this.city,
    this.state,
    this.phoneNumber,
    this.icon,
    this.reviews,
    this.rating,
    this.website,
    this.type,
    this.mapsUrl,
    this.mainPhoto,
    this.hours,
    this.photos,
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
    List<dynamic>? photos,
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
      photos: photos ?? this.photos,
    );
  }

  factory Place.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;

    return Place(
      placeId: snap['placeId'],
      state: snap['state'],
      name: snap['name'],
      address: snap['address'],
      city: snap['city'],
      reviews: data.containsKey('reviews') ? snap['reviews'] : null,
      rating: data.containsKey('rating') ? snap['rating'] : null,
      website: data.containsKey('website') ? snap['website'] : null,
      type: snap['type'],
      mainPhoto: snap['mainPhoto'],
      hours: data.containsKey('hours') ? snap['hours'] : null,
      mapsUrl: snap['mapsUrl'],
      phoneNumber: data.containsKey('phoneNumber') ? snap['phoneNumber'] : null,
      icon: snap['icon'],
      photos: data.containsKey('photos') ? snap['photos'] : null,
    );
  }

  factory Place.fromGooglePlace(GooglePlace googlePlace) {
    return Place(
      placeId: googlePlace.placeId,
      name: googlePlace.name,
      type: googlePlace.type,
      website: googlePlace.website,
      city: parseCityFromGooglePlace(googlePlace),
      state: parseStateFromGooglePlace(googlePlace),
      rating: googlePlace.rating,
      address: googlePlace.formattedAddress,
      phoneNumber: googlePlace.formattedPhoneNumber,
      icon: googlePlace.icon,
      mapsUrl: googlePlace.url,
      mainPhoto: googlePlace.photos?[0]['photo_reference'],
      hours: googlePlace.weekDayText,
      reviews: googlePlace.reviews,
      photos: googlePlace.photos,
    );
  }

  Map<String, Object?> toDocument() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'reviews': reviews,
      'rating': rating,
      'website': website,
      'type': type,
      'mainPhoto': mainPhoto,
      'hours': hours,
      'mapsUrl': mapsUrl,
      'phoneNumber': phoneNumber,
      'icon': icon,
      'photos': photos,
    };
  }
}
