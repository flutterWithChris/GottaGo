import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String name;
  final String address;
  final String city;
  final String? description;
  final String? review;
  final double? rating;
  final String? website;
  final String type;
  final String mainPhoto;
  final String? closingTime;
  Place({
    required this.name,
    required this.address,
    required this.city,
    required this.description,
    this.review,
    this.rating,
    this.website,
    required this.type,
    required this.mainPhoto,
    this.closingTime,
  });

  Place copyWith({
    String? name,
    String? address,
    String? city,
    String? description,
    String? review,
    double? rating,
    String? website,
    String? type,
    String? mainPhoto,
    String? closingTime,
  }) {
    return Place(
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      description: description ?? this.description,
      review: review ?? this.review,
      rating: rating ?? this.rating,
      website: website ?? this.website,
      type: type ?? this.type,
      mainPhoto: mainPhoto ?? this.mainPhoto,
      closingTime: closingTime ?? this.closingTime,
    );
  }

  factory Place.fromSnapshot(DocumentSnapshot snap) {
    return Place(
        name: snap.id,
        address: snap['address'],
        city: snap['city'],
        description: snap['description'],
        review: snap['review']!,
        rating: snap['rating'],
        website: snap['website'],
        type: snap['type'],
        mainPhoto: snap['mainPhoto'],
        closingTime: snap['closingTime']);
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'description': description ?? description!,
      'review': review ?? review!,
      'rating': rating ?? rating!,
      'website': website ?? website!,
      'type': type,
      'mainPhoto': mainPhoto,
      'closingTime': closingTime ?? closingTime!,
    };
  }
}
