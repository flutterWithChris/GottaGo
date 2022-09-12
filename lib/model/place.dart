class Place {
  final String name;
  final String address;
  final String city;
  final String? description;
  final String? review;
  final double? rating;
  final String? website;
  final String type;
  final String? mainPhoto;
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
    this.mainPhoto,
    this.closingTime,
  });
}
