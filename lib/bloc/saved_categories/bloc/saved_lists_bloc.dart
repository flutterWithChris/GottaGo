import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/repository/user_repository.dart';

part 'saved_lists_event.dart';
part 'saved_lists_state.dart';

class SavedListsBloc extends Bloc<SavedListsEvent, SavedListsState> {
  final PlaceListRepository _placeListRepository;
  final UserRepository _userRepository;
  final ProfileBloc _profileBloc;
  StreamSubscription? _profileSubscription;
  StreamSubscription? _savedListsSubscription;
  Stream<List<PlaceList>>? _placeListsStream;
  int placeCount = 0;
  int placeListCount = 0;

  List<PlaceList> myPlaceLists = [];
  List<PlaceList> sharedPlaceLists = [];
  List<PlaceList> allPlaceLists = [];
  SavedListsBloc({
    required ProfileBloc profileBloc,
    required PlaceListRepository placeListRepository,
    required UserRepository userRepository,
  })  : _placeListRepository = placeListRepository,
        _userRepository = userRepository,
        _profileBloc = profileBloc,
        super(SavedListsLoading()) {
    // add(LoadSavedLists());
    _profileSubscription = _profileBloc.stream.listen((state) {
      if (state is ProfileLoaded || state is ProfileIncomplete) {
        add(LoadSavedLists());
      }
    });
    on<LoadSavedLists>((event, emit) async {
      myPlaceLists.clear();
      sharedPlaceLists.clear();
      if (state is SavedListsLoading == false) {
        emit(SavedListsLoading());
      }

      _placeListsStream = _placeListRepository.getPlaceLists();
      myPlaceLists = await _placeListRepository
              .getMyPlaceListsFuture(profileBloc.state.user) ??
          [];
      // sharedPlaceLists =
      //     await _placeListRepository.getSharedPlaceListsFuture() ?? [];
      allPlaceLists = myPlaceLists + sharedPlaceLists;
      emit(SavedListsLoaded(
        placeListsStream: _placeListsStream,
      ));
    });
    on<AddList>((event, emit) async {
      emit(SavedListsLoading());
      await _placeListRepository.createPlaceList(event.placeList);
    });
    on<UpdateSavedLists>((event, emit) async {
      emit(SavedListsLoading());
      await _placeListRepository.updatePlaceLists(event.placeList);
      emit(SavedListsUpdated());
      add(LoadSavedLists());
    });
    on<RemoveList>((event, emit) async {
      emit(SavedListsLoading());
      await _placeListRepository.removePlaceList(event.placeList);
    });
  }
  @override
  Future<void> close() {
    // TODO: implement close
    _profileSubscription?.cancel();
    _savedListsSubscription?.cancel();
    return super.close();
  }
}
