part of 'saved_places_bloc.dart';

class SavedPlacesState extends Equatable {
  final PlaceList? placeList;
  final User? listOwner;
  final List<Place>? places;
  final List<User>? contributors;
  final Stream<List<Place>>? placeStream;
  const SavedPlacesState(
      {this.placeList,
      this.contributors,
      this.places,
      this.listOwner,
      this.placeStream});

  @override
  List<Object?> get props =>
      [placeList, contributors, places, listOwner, placeStream];
}

class SavedPlacesLoading extends SavedPlacesState {}

class SavedPlacesLoaded extends SavedPlacesState {
  @override
  final User listOwner;
  @override
  final List<Place> places;

  @override
  final List<User> contributors;
  @override
  final PlaceList placeList;
  @override
  final Stream<List<Place>> placeStream;
  const SavedPlacesLoaded(
      {required this.places,
      required this.listOwner,
      required this.placeList,
      required this.contributors,
      required this.placeStream});
  @override
  // TODO: implement props
  List<Object> get props =>
      [places, placeList, listOwner, contributors, placeStream];
}

class SavedPlacesFailed extends SavedPlacesState {}

class SavedPlacesUpdated extends SavedPlacesState {
  @override
  List<Place> places;
  SavedPlacesUpdated({
    required this.places,
  });
  @override
  // TODO: implement props
  List<Object> get props => [places];
}
