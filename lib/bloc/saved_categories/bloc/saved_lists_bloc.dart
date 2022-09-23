import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/repository/place_list_repository.dart';

part 'saved_lists_event.dart';
part 'saved_lists_state.dart';

class SavedListsBloc extends Bloc<SavedListsEvent, SavedListsState> {
  final PlaceListRepository _placeListRepository;
  int placeCount = 0;
  //StreamSubscription<PlaceList> _placeListSubscription;
  SavedListsBloc({required PlaceListRepository placeListRepository})
      : _placeListRepository = placeListRepository,
        super(SavedListsLoading()) {
    List<PlaceList> myPlaceLists = [];
    List<PlaceList> sharedPlaceLists = [];

    // _placeListSubscription =
    //     placeListRepository.getPlaceLists().listen((placeList) {
    //   add(UpdateSavedLists());
    // });
    on<SavedListsEvent>((event, emit) async {
      if (event is LoadSavedLists) {
        myPlaceLists.clear();

        // Get Place List & Fetch Contributors
        placeListRepository.getMyPlaceLists().listen((placeList) async {
          placeCount =
              await placeListRepository.getPlaceListItemCount(placeList);
          myPlaceLists.add(placeList.copyWith(placeCount: placeCount));
        });
        placeListRepository.getSharedPlaceLists().listen((placeList) async {
          placeCount =
              await placeListRepository.getPlaceListItemCount(placeList);
          sharedPlaceLists.add(placeList.copyWith(placeCount: placeCount));
        });

        await Future.delayed(const Duration(milliseconds: 500), () {});
        emit(SavedListsLoaded(
            placeLists: myPlaceLists, sharedPlaceLists: sharedPlaceLists));
      }
      if (event is AddList) {
        await placeListRepository.createPlaceList(event.placeList);
        emit(SavedListsUpdated());
        // await Future.delayed(const Duration(seconds: 1));
        add(LoadSavedLists());
      }
      if (event is UpdateSavedLists) {
        emit(SavedListsUpdated());
        add(LoadSavedLists());
      }
      if (event is RemoveList) {
        // myPlaceLists.remove(event.placeList);
        await placeListRepository.removePlaceList(event.placeList);
        emit(SavedListsUpdated());
        await Future.delayed(const Duration(milliseconds: 500));
        add(LoadSavedLists());
      }
      if (event is RearrangeSavedLists) {}
    });
  }
}
