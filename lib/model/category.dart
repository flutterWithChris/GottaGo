import 'package:flutter/material.dart';
import 'package:leggo/model/place.dart';

class Category {
  final String name;
  final IconData? icon;
  final List<Place>? places;
  final List<String> contributorIds;
  Category({
    required this.name,
    this.icon,
    this.places,
    required this.contributorIds,
  });
}
