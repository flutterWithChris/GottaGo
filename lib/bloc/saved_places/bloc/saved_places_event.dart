part of 'saved_places_bloc.dart';

abstract class SavedPlacesEvent extends Equatable {
  final Place? place;
  const SavedPlacesEvent({this.place});

  @override
  List<Object> get props => [place!];
}

class LoadPlaces extends SavedPlacesEvent {}

class AddPlace extends SavedPlacesEvent {
  @override
  final Place place;
  const AddPlace({
    required this.place,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place];
}

class RemovePlace extends SavedPlacesEvent {
  @override
  final Place place;
  const RemovePlace({
    required this.place,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place];
}

class UpdatePlace extends SavedPlacesEvent {
  @override
  final Place place;
  const UpdatePlace({
    required this.place,
  });
  @override
  // TODO: implement props
  List<Object> get props => [place];
}
