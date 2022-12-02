part of 'saved_places_bloc.dart';

class SavedPlacesState extends Equatable {
  final PlaceList? placeList;
  final List<User>? contributors;
  const SavedPlacesState({this.placeList, this.contributors});

  @override
  List<Object?> get props => [placeList, contributors];
}

class SavedPlacesLoading extends SavedPlacesState {}

class SavedPlacesLoaded extends SavedPlacesState {
  final User listOwner;
  final List<Place> places;

  @override
  final List<User> contributors;
  @override
  final PlaceList placeList;
  const SavedPlacesLoaded(
      {required this.places,
      required this.listOwner,
      required this.placeList,
      required this.contributors});
  @override
  // TODO: implement props
  List<Object> get props => [places, placeList, listOwner, contributors];
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
