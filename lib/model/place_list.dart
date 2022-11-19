import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlaceList {
  final String? placeListId;
  final String name;
  final String listOwnerId;
  final IconData? icon;
  // final List<Place>? places;
  final List<String> contributorIds;
  final int placeCount;
  PlaceList({
    this.placeListId,
    required this.name,
    required this.listOwnerId,
    this.icon,
    required this.placeCount,
    //  this.places,
    required this.contributorIds,
  });

  factory PlaceList.fromSnapshot(DocumentSnapshot snap) {
    return PlaceList(
        placeCount: snap['placeCount'],
        name: snap['name'],
        listOwnerId: snap['listOwnerId'],
        placeListId: snap.id,
        contributorIds: List.from(snap['contributorIds']));
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      'placeCount': placeCount,
      'listOwnerId': listOwnerId,
      //'iconData': icon,
      // 'places': places ?? places!,
      'contributorIds': contributorIds,
    };
  }

  PlaceList copyWith({
    String? placeListId,
    String? name,
    IconData? icon,
    int? placeCount,
    String? listOwnerId,
    //  List<Place>? places,
    List<String>? contributorIds,
  }) {
    return PlaceList(
      placeListId: placeListId ?? this.placeListId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      placeCount: placeCount ?? this.placeCount,
      listOwnerId: listOwnerId ?? this.listOwnerId,
      //   places: places ?? this.places,
      contributorIds: contributorIds ?? this.contributorIds,
    );
  }
}
