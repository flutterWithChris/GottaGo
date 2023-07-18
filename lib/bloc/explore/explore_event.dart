part of 'explore_bloc.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class LoadExplore extends ExploreEvent {
  final String placeType;
  final String? city;
  final String? state;
  final String? query;
  final String? negativeQuery;
  final String? positiveQuery;

  const LoadExplore(
      {required this.placeType,
      this.city,
      this.state,
      this.query,
      this.negativeQuery,
      this.positiveQuery});

  @override
  List<Object?> get props =>
      [placeType, city, state, query, negativeQuery, positiveQuery];
}

class SetLocation extends ExploreEvent {
  final String city;
  final String state;

  const SetLocation(this.city, this.state);

  @override
  List<Object?> get props => [city, state];
}

class SetQuery extends ExploreEvent {
  final String query;

  const SetQuery(this.query);

  @override
  List<Object> get props => [query];
}

class AddPlaceToList extends ExploreEvent {
  final Place place;
  final PlaceList placeList;

  const AddPlaceToList(this.place, this.placeList);

  @override
  List<Object> get props => [place, placeList];
}

class AddPlaceToNewList extends ExploreEvent {
  final Place place;
  final String placeListName;

  const AddPlaceToNewList(this.place, this.placeListName);

  @override
  List<Object> get props => [place, placeListName];
}
