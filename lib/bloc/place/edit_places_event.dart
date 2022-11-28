part of 'edit_places_bloc.dart';

abstract class EditPlacesEvent extends Equatable {
  const EditPlacesEvent();

  @override
  List<Object> get props => [];
}

class StartEditing extends EditPlacesEvent {}

class SelectPlace extends EditPlacesEvent {
  final Place place;
  const SelectPlace({
    required this.place,
  });
}

class UnselectPlace extends EditPlacesEvent {
  final Place place;
  const UnselectPlace({
    required this.place,
  });
}

class FinishEditing extends EditPlacesEvent {
  final List<Place> places;
  final PlaceList placeList;
  const FinishEditing({
    required this.places,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [places, placeList];
}

class DeletePlaces extends EditPlacesEvent {
  final PlaceList placeList;
  const DeletePlaces({
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [placeList];
}

class DeletePlace extends EditPlacesEvent {
  final Place place;
  final PlaceList placeList;
  const DeletePlace({
    required this.place,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place, placeList];
}

class DeleteVisitedPlace extends EditPlacesEvent {
  final Place place;
  final PlaceList placeList;
  const DeleteVisitedPlace({
    required this.place,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place, placeList];
}

class DeleteVisitedPlaces extends EditPlacesEvent {
  final PlaceList placeList;
  const DeleteVisitedPlaces({
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [placeList];
}

class MarkVisitedPlaces extends EditPlacesEvent {
  final PlaceList placeList;
  const MarkVisitedPlaces({
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [placeList];
}

class MarkVisitedPlace extends EditPlacesEvent {
  final Place place;
  final PlaceList placeList;
  const MarkVisitedPlace({
    required this.place,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place, placeList];
}

class UnVisitPlace extends EditPlacesEvent {
  final Place place;
  final PlaceList placeList;
  const UnVisitPlace({
    required this.place,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place, placeList];
}

class CancelEditing extends EditPlacesEvent {}
