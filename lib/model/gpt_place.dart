class GptPlace {
  final String name;
  final String type;
  final String description;
  final String city;
  final String state;

  const GptPlace({
    required this.name,
    required this.type,
    required this.description,
    required this.city,
    required this.state,
  });

  factory GptPlace.fromJson(Map<String, dynamic> json) {
    return GptPlace(
      name: json['name'],
      type: json['type'],
      description: json['description'],
      city: json['city'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'city': city,
      'state': state,
    };
  }
}
