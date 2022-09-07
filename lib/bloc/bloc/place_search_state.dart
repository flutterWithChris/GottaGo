part of 'place_search_bloc.dart';

enum Status { initial, loading, loaded, failed }

class PlaceSearchState {
  Status status;
  DetailsResult? detailsResult;
  PlaceSearchState({required this.status, this.detailsResult});

  factory PlaceSearchState.initial() {
    return PlaceSearchState(status: Status.initial);
  }

  factory PlaceSearchState.loading() {
    return PlaceSearchState(status: Status.loading);
  }

  factory PlaceSearchState.loaded(DetailsResult detailsResult) {
    return PlaceSearchState(
        status: Status.loaded, detailsResult: detailsResult);
  }

  factory PlaceSearchState.failed() {
    return PlaceSearchState(status: Status.failed);
  }
}
