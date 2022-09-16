import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String profilePicture;
  // final List<PlaceList>? placeLists;
  const User({
    this.id,
    required this.name,
    required this.email,
    required this.profilePicture,
    //  this.placeLists,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    // List<PlaceList>? placeLists,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      //   placeLists: placeLists ?? this.placeLists,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snap) {
    return User(
      id: snap.id,
      name: snap['name'],
      email: snap['email'],
      profilePicture: snap['profilePicture'],
      //   placeLists: snap['placeLists'] as List<PlaceList>,
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
