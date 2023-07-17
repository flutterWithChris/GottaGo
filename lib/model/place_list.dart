import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceList {
  final String? placeListId;
  final String name;
  final String listOwnerId;
  final Map<String, dynamic> icon;
  // final List<Place>? places;
  final List<String>? contributorIds;
  final int placeCount;
  PlaceList({
    this.placeListId,
    required this.name,
    required this.listOwnerId,
    required this.icon,
    required this.placeCount,
    //  this.places,
    this.contributorIds,
  });

  factory PlaceList.fromSnapshot(DocumentSnapshot snap) {
    return PlaceList(
        placeCount: snap['placeCount'],
        name: snap['name'],
        icon: snap['icon'],
        listOwnerId: snap['listOwnerId'],
        placeListId: snap.id,
        contributorIds: List.from(snap['contributorIds']));
  }

  Map<String, Object> toDocument() {
    return {
      'name': name,
      'placeCount': placeCount,
      'listOwnerId': listOwnerId,
      'icon': icon,
      // 'places': places ?? places!,
      'contributorIds': contributorIds ?? contributorIds!,
    };
  }

  PlaceList copyWith({
    String? placeListId,
    String? name,
    Map<String, dynamic>? icon,
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
