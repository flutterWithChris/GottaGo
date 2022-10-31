part of 'place_search_bloc.dart';

enum Status { initial, started, focused, unfocused, loading, loaded, failed }

class PlaceSearchState extends Equatable {
  Status status;
  List<PlaceSearch>? searchResults;

  PlaceSearchState({required this.status, this.searchResults});

  factory PlaceSearchState.initial() {
    return PlaceSearchState(status: Status.initial);
  }

  factory PlaceSearchState.loading() {
    return PlaceSearchState(status: Status.loading);
  }

  factory PlaceSearchState.loaded() {
    return PlaceSearchState(status: Status.loaded);
  }

  factory PlaceSearchState.failed() {
    return PlaceSearchState(status: Status.failed);
  }

  factory PlaceSearchState.started() {
    return PlaceSearchState(status: Status.started);
  }

  factory PlaceSearchState.focused() {
    return PlaceSearchState(status: Status.focused);
  }

  factory PlaceSearchState.unfocused() {
    return PlaceSearchState(status: Status.unfocused);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status];
}
