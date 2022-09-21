part of 'saved_places_bloc.dart';

class SavedPlacesState extends Equatable {
  final PlaceList? placeList;
  const SavedPlacesState({
    this.placeList,
  });

  @override
  List<Object?> get props => [placeList];
}

class SavedPlacesLoading extends SavedPlacesState {}

class SavedPlacesLoaded extends SavedPlacesState {
  final List<Place> places;
  @override
  final PlaceList placeList;
  const SavedPlacesLoaded({
    required this.places,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [places, placeList];
}

class SavedPlacesFailed extends SavedPlacesState {}

class SavedPlacesUpdated extends SavedPlacesState {
  List<Place> places;
  SavedPlacesUpdated({
    required this.places,
  });
  @override
  // TODO: implement props
  List<Object> get props => [places];
}
