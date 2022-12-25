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
  SavedListsLoaded({required this.placeLists});
  @override
  // TODO: implement props
  List<Object?> get props => [placeLists];
}

class SavedListsFailed extends SavedListsState {}

class SavedListsUpdated extends SavedListsState {}
