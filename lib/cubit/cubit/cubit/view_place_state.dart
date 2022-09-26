part of 'view_place_cubit.dart';

abstract class ViewPlaceState extends Equatable {
  final Place? place;
  final DetailsResponse? googlePlaceDetails;
  const ViewPlaceState({this.place, this.googlePlaceDetails});

  @override
  List<Object> get props => [place!, googlePlaceDetails!];
}

class ViewPlaceInitial extends ViewPlaceState {}

class ViewPlaceLoading extends ViewPlaceState {}

class ViewPlaceLoaded extends ViewPlaceState {
  @override
  final Place place;

  @override
  final DetailsResponse googlePlaceDetails;
  const ViewPlaceLoaded(
      {required this.place, required this.googlePlaceDetails});
  @override
  // TODO: implement props
  List<Object> get props => [place, googlePlaceDetails];
}

class ViewPlaceFailed extends ViewPlaceState {}
