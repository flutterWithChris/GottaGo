part of 'edit_places_bloc.dart';

abstract class EditPlacesState extends Equatable {
  List<Place>? places;
  PlaceList? placeList;
  EditPlacesState({this.places, this.placeList});

  @override
  List<Object?> get props => [places, placeList];
}

class EditPlacesInitial extends EditPlacesState {}

class EditPlacesStarted extends EditPlacesState {}

class EditPlacesSubmitted extends EditPlacesState {
  @override
  final List<Place> places;
  @override
  final PlaceList placeList;
  EditPlacesSubmitted({
    required this.places,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [places, placeList];
}

class EditPlacesLoading extends EditPlacesState {}

class EditPlacesComplete extends EditPlacesState {}

class EditPlacesFailed extends EditPlacesState {
  @override
  final List<Place> places;
  @override
  final PlaceList placeList;
  EditPlacesFailed({
    required this.places,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [places, placeList];
}

class PlaceAdded extends EditPlacesState {
  final Place place;
  PlaceAdded({
    required this.place,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [place];
}

class PlaceRemoved extends EditPlacesState {
  final Place place;
  PlaceRemoved({
    required this.place,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [place];
}
