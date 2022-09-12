part of 'saved_places_bloc.dart';

abstract class SavedPlacesState extends Equatable {
  const SavedPlacesState();

  @override
  List<Object> get props => [];
}

class SavedPlacesLoading extends SavedPlacesState {}

class SavedPlacesLoaded extends SavedPlacesState {
  List<Place> places;
  SavedPlacesLoaded({
    required this.places,
  });
  @override
  // TODO: implement props
  List<Object> get props => [places];
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
