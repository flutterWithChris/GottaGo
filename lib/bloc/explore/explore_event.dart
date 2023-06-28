part of 'explore_bloc.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object> get props => [];
}

class LoadExplore extends ExploreEvent {
  final String placeType;
  final String city;
  final String state;

  const LoadExplore(
      {required this.placeType, required this.city, required this.state});

  @override
  List<Object> get props => [placeType, city, state];
}
