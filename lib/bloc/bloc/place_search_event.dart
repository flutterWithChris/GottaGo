part of 'place_search_bloc.dart';

@immutable
abstract class PlaceSearchEvent extends Equatable {
  AutocompletePrediction? suggestion;
  DetailsResult? result;
  String? searchTerm;
  PlaceSearchEvent({
    this.suggestion,
    this.result,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [suggestion, result, searchTerm];
}

class PlaceSelected extends PlaceSearchEvent {
  @override
  AutocompletePrediction? suggestion;
  PlaceSelected({
    required this.suggestion,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [suggestion];
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
