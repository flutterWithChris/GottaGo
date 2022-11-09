part of 'place_bloc.dart';

abstract class PlaceState extends Equatable {
  const PlaceState();

  @override
  List<Object> get props => [];
}

class PlaceLoading extends PlaceState {}

class PlaceLoaded extends PlaceState {
  final GooglePlace googlePlace;
  const PlaceLoaded({
    required this.googlePlace,
  });
  @override
  // TODO: implement props
  List<Object> get props => [googlePlace];
}

class PlaceFailed extends PlaceState {}
