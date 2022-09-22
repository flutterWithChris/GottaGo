import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String profilePicture;
  final List<String>? placeListIds;
  const User({
    this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    this.placeListIds,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    final List<String>? placeListIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      placeListIds: placeListIds ?? this.placeListIds,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snap) {
    return User(
      id: snap.id,
      name: snap['name'],
      email: snap['email'],
      profilePicture: snap['profilePicture'],
      placeListIds: List.from(snap['placeListIds']),
    );
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      //   'placeLists': placeLists!.asMap(),
    };
  }

  @override
  List<Object?> get props => [id!, name, email, profilePicture];
}
