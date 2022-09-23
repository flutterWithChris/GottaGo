import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlaceList {
  final String? placeListId;
  final String name;

  final String listOwnerId;
  final IconData? icon;
  // final List<Place>? places;
  final List<String>? contributorIds;
  final int? placeCount;
  PlaceList({
    this.placeListId,
    required this.name,
    required this.listOwnerId,
    this.icon,
    this.placeCount,
    //  this.places,
    this.contributorIds,
  });

  factory PlaceList.fromSnapshot(DocumentSnapshot snap) {
    return PlaceList(
        name: snap['name'],
        listOwnerId: snap['listOwnerId'],
        placeListId: snap.id,
        contributorIds: List.from(snap['contributorIds']));
  }

  Map<String, Object> toDocument() {
    return {
      'placeListId': placeListId ?? '',
      'name': name,
      'placeCount': placeCount ?? 0,
      'listOwnerId': listOwnerId,
      //'iconData': icon,
      // 'places': places ?? places!,
      'contributorIds': contributorIds ?? [''],
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
