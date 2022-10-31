part of 'view_place_cubit.dart';

abstract class ViewPlaceState extends Equatable {
  final Place? place;

  const ViewPlaceState({this.place});

  @override
  List<Object> get props => [place!];
}

class ViewPlaceInitial extends ViewPlaceState {}

class ViewPlaceLoading extends ViewPlaceState {}

class ViewPlaceLoaded extends ViewPlaceState {
  @override
  final Place place;

  @override
  const ViewPlaceLoaded({required this.place});
  @override
  // TODO: implement props
  List<Object> get props => [place];
}

class ViewPlaceFailed extends ViewPlaceState {}
