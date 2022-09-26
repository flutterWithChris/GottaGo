part of 'random_wheel_cubit.dart';

abstract class RandomWheelState extends Equatable {
  final List<Place>? places;
  final Place? selectedPlace;
  const RandomWheelState({this.places, this.selectedPlace});

  @override
  List<Object> get props => [places!, selectedPlace!];
}

class RandomWheelInitial extends RandomWheelState {}

class RandomWheelLoading extends RandomWheelState {}

class RandomWheelLoaded extends RandomWheelState {
  @override
  final List<Place> places;
  const RandomWheelLoaded({required this.places});
  @override
  // TODO: implement props
  List<Object> get props => [places];
}

class RandomWheelSpun extends RandomWheelState {}

class RandomWheelChosen extends RandomWheelState {
  @override
  final Place selectedPlace;
  DetailsResponse? googlePlaceDetails;
  RandomWheelChosen({required this.selectedPlace, this.googlePlaceDetails});
  @override
  // TODO: implement props
  List<Object> get props => [selectedPlace, googlePlaceDetails!];
}

class RandomWheelFailed extends RandomWheelState {}
