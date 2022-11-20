import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String? userName;
  final String? name;
  final String? email;
  final String? profilePicture;
  final List<String>? placeListIds;

  const User({
    this.id,
    this.userName,
    this.name,
    this.email,
    this.profilePicture,
    this.placeListIds,
  });

  static const empty = User(id: '');

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => this != User.empty;

  User copyWith({
    String? id,
    String? userName,
    String? name,
    String? email,
    String? profilePicture,
    final List<String>? placeListIds,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      placeListIds: placeListIds ?? this.placeListIds,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snap) {
    return User(
      id: snap.id,
      userName: snap['userName'],
      name: snap['name'],
      email: snap['email'],
      profilePicture: snap['profilePicture'],
      placeListIds: List.from(snap['placeListIds']),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'userName': userName,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'placeListIds': placeListIds,
      //   'placeLists': placeLists!.asMap(),
    };
  }

  @override
  List<Object?> get props => [id, name, userName, email, profilePicture];
}
