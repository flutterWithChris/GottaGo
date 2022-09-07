part of 'place_search_bloc.dart';

@immutable
abstract class PlaceSearchEvent {}

class PlaceSelected extends PlaceSearchEvent {
  DetailsResult detailsResult;
  PlaceSelected({
    required this.detailsResult,
  });
}

class PlaceSearch extends PlaceSearchEvent {}
