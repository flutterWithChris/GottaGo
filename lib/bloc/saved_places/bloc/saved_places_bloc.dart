import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/place_list_repository.dart';

part 'saved_places_event.dart';
part 'saved_places_state.dart';

class SavedPlacesBloc extends Bloc<SavedPlacesEvent, SavedPlacesState> {
  final PlaceListRepository _placeListRepository;
  Stream<User>? contributorStream;
  SavedPlacesBloc({required PlaceListRepository placeListRepository})
      : _placeListRepository = placeListRepository,
        super(SavedPlacesLoading()) {
    final List<Place> savedPlaces = [];
    List<User> contributors = [];
    User? listOwner;

    on<SavedPlacesEvent>((event, emit) async {
      if (event is LoadPlaces) {
        emit(SavedPlacesLoading());
        savedPlaces.clear();
        contributors.clear();
        placeListRepository.getPlaces(event.placeList).listen((place) {
          savedPlaces.add(place);
        });
        if (event.placeList.contributorIds![0] != '') {
          placeListRepository
              .getListContributors(event.placeList)!
              .listen((user) {
            contributors.add(user);
          });
        }

        placeListRepository.getListOwner(event.placeList).listen((user) {
          listOwner = user;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        emit(SavedPlacesLoaded(
            listOwner: listOwner!,
            places: savedPlaces,
            placeList: event.placeList,
            contributors: contributors));
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
        emit(SavedPlacesUpdated(places: savedPlaces));
        add(LoadPlaces(placeList: event.placeList));
      }
    });
  }
  @override
  Future<void> close() {
    // TODO: implement close

    return super.close();
  }
}
