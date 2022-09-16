part of 'saved_lists_bloc.dart';

abstract class SavedListsEvent extends Equatable {
  const SavedListsEvent();

  @override
  List<Object> get props => [];
}

class AddList extends SavedListsEvent {
  final PlaceList placeList;
  const AddList({required this.placeList});
  @override
  // TODO: implement props
  List<Object> get props => [placeList];
}

class RemoveList extends SavedListsEvent {
  final PlaceList placeList;
  const RemoveList({
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [props];
}

class EditList extends SavedListsEvent {
  final PlaceList placeList;
  const EditList({
    required this.placeList,
  });
  @override
  // TODO: implement props
  List<Object> get props => [placeList];
}

class LoadSavedLists extends SavedListsEvent {}

class UpdateSavedLists extends SavedListsEvent {}
