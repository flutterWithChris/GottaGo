import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/repository/user_repository.dart';

part 'saved_places_event.dart';
part 'saved_places_state.dart';

class SavedPlacesBloc extends Bloc<SavedPlacesEvent, SavedPlacesState> {
  final PlaceListRepository _placeListRepository;
  final SavedListsBloc _savedListsBloc;
  final UserRepository _userRepository;
  StreamSubscription? _savedListsSubscription;
  StreamSubscription? placeListsSubscription;
  PlaceList? _currentPlaceList;
  Stream<User>? contributorStream;
  Stream<List<Place>>? placeStream;
  SavedPlacesBloc({
    required PlaceListRepository placeListRepository,
    required SavedListsBloc savedListsBloc,
    required UserRepository userRepository,
  })  : _placeListRepository = placeListRepository,
        _savedListsBloc = savedListsBloc,
        _userRepository = userRepository,
        super(SavedPlacesLoading()) {
    final List<Place> savedPlaces = [];
    final List<Place> visitedPlaces = [];
    List<User> contributors = [];

    User? listOwner;
    _savedListsSubscription = _savedListsBloc.stream.listen((state) {
      if (state is SavedListsUpdated) {
        add(LoadPlaces(placeList: _currentPlaceList!));
      }
    });

    if (state.placeList != null) {
      placeListsSubscription =
          _placeListRepository.getPlaces(state.placeList!).listen((place) {
        add(LoadPlaces(placeList: state.placeList!));
      });
    }

    on<SavedPlacesEvent>((event, emit) async {
      if (event is LoadPlaces) {
        emit(SavedPlacesLoading());
        savedPlaces.clear();
        contributors.clear();

        _placeListRepository
            .getPlaceList(event.placeList.placeListId!)!
            .listen((placeList) {
          _currentPlaceList = placeList;
          placeListRepository.getPlaces(event.placeList).listen((place) {
            savedPlaces.add(place);
          });

          if (placeList.contributorIds.isNotEmpty) {
            for (String userId in placeList.contributorIds) {
              _userRepository.getUser(userId).listen((user) {
                contributors.add(user);
              });
            }
          }
        });

        placeStream = _placeListRepository.getPlacesList(event.placeList);

        placeListRepository.getListOwner(event.placeList).listen((user) {
          listOwner = user;
        });
        await Future.delayed(const Duration(seconds: 1));
        emit(SavedPlacesLoaded(
            listOwner: listOwner!,
            places: savedPlaces,
            placeList: event.placeList,
            contributors: contributors,
            placeStream: placeStream!));
      }
      if (event is LoadVisitedPlaces) {
        emit(SavedPlacesLoading());
        savedPlaces.clear();
        contributors.clear();

        _placeListRepository
            .getPlaceList(event.placeList.placeListId!)!
            .listen((placeList) {
          placeListRepository.getVisitedPlaces(event.placeList).listen((place) {
            savedPlaces.add(place);
          });

          if (placeList.contributorIds.isNotEmpty) {
            for (String userId in placeList.contributorIds) {
              _userRepository.getUser(userId).listen((user) {
                contributors.add(user);
              });
            }
          }
        });

        placeStream =
            _placeListRepository.getVisitedPlacesList(event.placeList);

        placeListRepository.getListOwner(event.placeList).listen((user) {
          listOwner = user;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        emit(SavedPlacesLoaded(
            listOwner: listOwner!,
            places: savedPlaces,
            placeList: event.placeList,
            contributors: contributors,
            placeStream: placeStream!));
      }
      if (event is AddPlace) {
        placeListRepository.addPlaceToList(event.place, event.placeList);
        emit(SavedPlacesLoading());
        //savedPlaces.insert(0, event.place);
        await Future.delayed(const Duration(milliseconds: 500));
        emit(SavedPlacesUpdated(places: savedPlaces));
        add(LoadPlaces(placeList: event.placeList));
      }
      if (event is RemovePlace) {
        emit(SavedPlacesLoading());
        await Future.delayed(
            const Duration(seconds: 1), () => savedPlaces.remove(event.place));
        emit(SavedPlacesUpdated(places: savedPlaces));
        add(LoadPlaces(placeList: event.placeList));
      }
      if (event is UpdatePlace) {
        // emit(SavedPlacesUpdated(places: savedPlaces));
        add(LoadPlaces(placeList: state.placeList!));
      }
    });
  }
  @override
  Future<void> close() {
    // TODO: implement close
    placeListsSubscription?.cancel();
    _savedListsSubscription?.cancel();
    return super.close();
  }
}
