import 'package:flutter/cupertino.dart';
import 'package:leggo/model/place_list.dart';

final HeroController heroController = HeroController();

List<PlaceList>? samplePlaceLists = [
  PlaceList(
      name: 'Lunch Spots',
      listOwnerId: '12345',
      placeCount: 7,
      contributorIds: [],
      icon: {'pack': 'fontAwesomeIcons', 'key': 'bowlFood'}),
  PlaceList(
      name: 'Iceland Trip',
      listOwnerId: '12345',
      placeCount: 12,
      contributorIds: [],
      icon: {'pack': 'fontAwesomeIcons', 'key': 'earthAmericas'}),
  PlaceList(
      name: 'Breakfast Ideas',
      listOwnerId: '12345',
      placeCount: 5,
      contributorIds: [],
      icon: {'pack': 'material', 'key': 'egg_alt_outlined'}),
  PlaceList(
      name: 'Experiences',
      listOwnerId: '12345',
      placeCount: 9,
      contributorIds: [],
      icon: {'pack': 'material', 'key': 'airplane_ticket_rounded'}),
  PlaceList(
    name: 'Local Spots',
    listOwnerId: '12345',
    placeCount: 10,
    contributorIds: [],
    icon: {'pack': 'material', 'key': 'local_dining'},
  ),
];
