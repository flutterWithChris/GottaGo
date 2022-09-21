import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlaceList {
  final String name;
  final IconData? icon;
  // final List<Place>? places;
  //final List<String>? contributorIds;
  final int? placeCount;
  PlaceList({
    required this.name,
    this.icon,
    this.placeCount,
    //  this.places,
    //this.contributorIds,
  });

  factory PlaceList.fromSnapshot(DocumentSnapshot snap) {
    return PlaceList(name: snap.id);
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      'placeCount': placeCount ?? 0,
      //'iconData': icon,
      // 'places': places ?? places!,
      // 'contributorIds': contributorIds ?? '',
    };
  }

  PlaceList copyWith({
    String? name,
    IconData? icon,
    int? placeCount,
    //  List<Place>? places,
    List<String>? contributorIds,
  }) {
    return PlaceList(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      placeCount: placeCount ?? this.placeCount,
      //   places: places ?? this.places,
      // contributorIds: contributorIds ?? this.contributorIds,
    );
  }
}
