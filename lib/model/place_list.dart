import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:leggo/model/place.dart';

class PlaceList {
  final String name;
  final IconData? icon;
  final List<Place>? places;
  final List<String>? contributorIds;
  PlaceList({
    required this.name,
    this.icon,
    this.places,
    this.contributorIds,
  });

  factory PlaceList.fromSnapshot(DocumentSnapshot snap) {
    return PlaceList(name: snap.id);
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      //'iconData': icon,
      //  'places': places!,
      //   'contributorIds': contributorIds,
    };
  }

  PlaceList copyWith({
    String? name,
    IconData? icon,
    //  List<Place>? places,
    // List<String>? contributorIds,
  }) {
    return PlaceList(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      //    places: places ?? this.places,
      //   contributorIds: contributorIds ?? this.contributorIds,
    );
  }
}
