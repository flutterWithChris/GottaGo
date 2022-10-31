part of 'place_search_bloc.dart';

@immutable
abstract class PlaceSearchEvent extends Equatable {
  String? searchTerm;

  @override
  // TODO: implement props
  List<Object?> get props => [searchTerm];
}

class PlaceSelected extends PlaceSearchEvent {
  @override
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class PlaceSearchStarted extends PlaceSearchEvent {
  @override
  String? searchTerm;
  PlaceSearchStarted({
    required this.searchTerm,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [searchTerm];
}

class PlaceSearchSubmit extends PlaceSearchEvent {}

class PlaceSearchbarClicked extends PlaceSearchEvent {}

class PlaceSearchbarClosed extends PlaceSearchEvent {}
