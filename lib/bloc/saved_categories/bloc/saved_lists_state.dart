part of 'saved_lists_bloc.dart';

abstract class SavedListsState extends Equatable {
  List<PlaceList>? placeLists;
  Stream<List<PlaceList>>? placeListsStream;
  final PlaceList? placeList;
  final User? listOwner;
  final List<Place>? places;
  SavedListsState(
      {this.placeLists,
      this.placeListsStream,
      this.placeList,
      this.listOwner,
      this.places});

  @override
  List<Object?> get props =>
      [placeLists, placeListsStream, placeList, listOwner, places];
}

class SavedListsInitial extends SavedListsState {}

class SavedListsLoading extends SavedListsState {}

class SavedListsLoaded extends SavedListsState {
  @override
  final Stream<List<PlaceList>>? placeListsStream;
  SavedListsLoaded({this.placeListsStream});
  @override
  // TODO: implement props
  List<Object?> get props => [placeListsStream];
}

class SavedListsFailed extends SavedListsState {}

class SavedListsUpdated extends SavedListsState {}
