import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/place_list.dart';

part 'saved_lists_event.dart';
part 'saved_lists_state.dart';

class SavedListsBloc extends Bloc<SavedListsEvent, SavedListsState> {
  SavedListsBloc() : super(SavedListsLoading()) {
    List<PlaceList> myPlaceLists = [];
    on<SavedListsEvent>((event, emit) async {
      if (event is LoadSavedLists) {
        await Future.delayed(const Duration(seconds: 2));
        emit(SavedListsLoaded(placeLists: myPlaceLists));
      }
      if (event is AddList) {
        myPlaceLists.add(event.placeList);
        emit(SavedListsUpdated(placeList: event.placeList));
        await Future.delayed(const Duration(seconds: 1));
        emit(SavedListsLoaded(placeLists: myPlaceLists));
      }
      if (event is UpdateSavedLists) {
        emit(SavedListsLoaded(placeLists: myPlaceLists));
      }
      if (event is RemoveList) {
        emit(SavedListsUpdated(placeList: event.placeList));
        await Future.delayed(const Duration(seconds: 1));
        add(LoadSavedLists());
      }
    });
  }
}
