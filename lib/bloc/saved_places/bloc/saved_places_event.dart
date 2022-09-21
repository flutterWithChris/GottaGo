part of 'saved_places_bloc.dart';

abstract class SavedPlacesEvent extends Equatable {
  final Place? place;
  final PlaceList? placeList;
  const SavedPlacesEvent({this.place, this.placeList});

  @override
  List<Object> get props => [place!];
}

class LoadPlaces extends SavedPlacesEvent {
  @override
  final PlaceList placeList;
  const LoadPlaces({
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [placeList];
}

class AddPlace extends SavedPlacesEvent {
  @override
  final Place place;
  @override
  final PlaceList placeList;
  const AddPlace({required this.place, required this.placeList});
  @override
  // TODO: implement props
  List<Object> get props => [place, placeList];
}

class RemovePlace extends SavedPlacesEvent {
  @override
  final PlaceList placeList;
  @override
  final Place place;
  const RemovePlace({
    required this.place,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place];
}

class UpdatePlace extends SavedPlacesEvent {
  @override
  final Place place;
  @override
  final PlaceList placeList;
  const UpdatePlace({
    required this.place,
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place];
}
