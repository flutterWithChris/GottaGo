part of 'saved_lists_bloc.dart';

abstract class SavedListsState extends Equatable {
  List<PlaceList>? placeLists;
  SavedListsState({this.placeLists});

  @override
  List<Object?> get props => [placeLists];
}

class SavedListsLoading extends SavedListsState {}

class SavedListsLoaded extends SavedListsState {
  @override
  final List<PlaceList>? placeLists;
  final List<PlaceList>? sharedPlaceLists;
  SavedListsLoaded({required this.placeLists, required this.sharedPlaceLists});
  @override
  // TODO: implement props
  List<Object?> get props => [placeLists, sharedPlaceLists];
}

class SavedListsFailed extends SavedListsState {}

class SavedListsUpdated extends SavedListsState {}
