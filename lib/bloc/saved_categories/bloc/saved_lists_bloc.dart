import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/repository/place_list_repository.dart';

part 'saved_lists_event.dart';
part 'saved_lists_state.dart';

class SavedListsBloc extends Bloc<SavedListsEvent, SavedListsState> {
  final PlaceListRepository _placeListRepository;
  //StreamSubscription<PlaceList> _placeListSubscription;
  SavedListsBloc({required PlaceListRepository placeListRepository})
      : _placeListRepository = placeListRepository,
        super(SavedListsLoading()) {
    List<PlaceList> myPlaceLists = [];
    // _placeListSubscription =
    //     placeListRepository.getPlaceLists().listen((placeList) {
    //   add(UpdateSavedLists());
    // });
    on<SavedListsEvent>((event, emit) async {
      if (event is LoadSavedLists) {
        myPlaceLists.clear();
        placeListRepository.getPlaceLists().listen((placeList) {
          myPlaceLists.add(placeList);
        });
        await Future.delayed(const Duration(seconds: 1), () {});
        emit(SavedListsLoaded(placeLists: myPlaceLists));
      }
      if (event is AddList) {
        await placeListRepository.createPlaceList(event.placeList);
        emit(SavedListsUpdated(placeList: event.placeList));
        // await Future.delayed(const Duration(seconds: 1));
        add(LoadSavedLists());
      }
      if (event is UpdateSavedLists) {
        add(LoadSavedLists());
      }
      if (event is RemoveList) {
        // myPlaceLists.remove(event.placeList);
        await placeListRepository.removePlaceList(event.placeList);
        emit(SavedListsUpdated(placeList: event.placeList));
        await Future.delayed(const Duration(seconds: 1));
        add(LoadSavedLists());
      }
      if (event is RearrangeSavedLists) {}
    });
  }
}
