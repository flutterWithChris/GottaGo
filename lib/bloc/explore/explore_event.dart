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

  const LoadExplore(
      {required this.placeType, this.city, this.state, this.query});

  @override
  List<Object?> get props => [placeType, city, state, query];
}

class SetLocation extends ExploreEvent {
  final String location;

  const SetLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class SetQuery extends ExploreEvent {
  final String query;

  const SetQuery(this.query);

  @override
  List<Object> get props => [query];
}
