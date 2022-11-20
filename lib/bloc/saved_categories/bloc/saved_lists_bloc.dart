import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/repository/user_repository.dart';

part 'saved_lists_event.dart';
part 'saved_lists_state.dart';

class SavedListsBloc extends Bloc<SavedListsEvent, SavedListsState> {
  final PlaceListRepository _placeListRepository;
  final UserRepository _userRepository;
  final ProfileBloc _profileBloc;
  StreamSubscription? _profileSubscription;
  int placeCount = 0;

  List<PlaceList> myPlaceLists = [];
  List<PlaceList> sharedPlaceLists = [];
  SavedListsBloc({
    required ProfileBloc profileBloc,
    required PlaceListRepository placeListRepository,
    required UserRepository userRepository,
  })  : _placeListRepository = placeListRepository,
        _userRepository = userRepository,
        _profileBloc = profileBloc,
        super(SavedListsLoading()) {
    _profileSubscription = _profileBloc.stream.listen((state) {
      if (state is ProfileLoaded) {
        add(LoadSavedLists());
      }
    });
    on<SavedListsEvent>((event, emit) async {
      myPlaceLists.clear();
      sharedPlaceLists.clear();
      if (event is LoadSavedLists) {
        // _userRepository
        //     .getUser(auth.FirebaseAuth.instance.currentUser!.uid)
        //     .listen((user) {
        //   placeListRepository.getMyPlaceLists(user)?.listen((placeList) async {
        //     placeCount =
        //         await placeListRepository.getPlaceListItemCount(placeList);
        //     myPlaceLists.add(placeList.copyWith(placeCount: placeCount));
        //   });
        // });
        print(
            'Place List Ids Null?: ${_profileBloc.state.user.placeListIds == null}');
        if (_profileBloc.state.user.placeListIds != null) {
          await emit.forEach(
            placeListRepository
                .getMyPlaceLists(_profileBloc.state.user.placeListIds!),
            onData: (placeList) {
              //  placeCount =
              // await placeListRepository.getPlaceListItemCount(placeList);
              myPlaceLists.add(placeList!.copyWith(placeCount: placeCount));
              return SavedListsLoaded(
                  placeLists: myPlaceLists, sharedPlaceLists: sharedPlaceLists);
            },
            onError: (error, stackTrace) => SavedListsFailed(),
          );
        } else {
          emit(SavedListsLoaded(
              placeLists: const [], sharedPlaceLists: const []));
        }
        // placeListRepository.getMyPlaceLists(user)?.listen((placeList) async {
        //   placeCount =
        //       await placeListRepository.getPlaceListItemCount(placeList);
        //   myPlaceLists.add(placeList.copyWith(placeCount: placeCount));
        // });

        // Get Place List & Fetch Contributors

        // placeListRepository.getSharedPlaceLists().listen((placeList) async {
        //   placeCount =
        //       await placeListRepository.getPlaceListItemCount(placeList);
        //   sharedPlaceLists.add(placeList.copyWith(placeCount: placeCount));
        // });

        // await Future.delayed(const Duration(milliseconds: 500), () {});
        // emit(SavedListsLoaded(
        //     placeLists: myPlaceLists, sharedPlaceLists: sharedPlaceLists));
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
