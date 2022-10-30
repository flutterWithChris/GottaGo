part of 'place_search_bloc.dart';

enum Status { initial, loading, loaded, failed }

class PlaceSearchState extends Equatable {
  List<AutocompletePrediction>? predictions;
  Status status;
  DetailsResult? detailsResult;
  PlaceSearchState(
      {required this.status, this.detailsResult, this.predictions});

  factory PlaceSearchState.initial() {
    return PlaceSearchState(status: Status.initial);
  }

  factory PlaceSearchState.loading(List<AutocompletePrediction> predictions) {
    return PlaceSearchState(status: Status.loading, predictions: predictions);
  }

  factory PlaceSearchState.loaded(DetailsResult detailsResult) {
    return PlaceSearchState(
        status: Status.loaded, detailsResult: detailsResult);
  }

  factory PlaceSearchState.failed() {
    return PlaceSearchState(status: Status.failed);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, detailsResult];
}
