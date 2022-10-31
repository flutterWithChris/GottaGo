import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:leggo/data/services/places_service.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/place_search.dart';
import 'package:rxdart/rxdart.dart';

part 'place_search_event.dart';
part 'place_search_state.dart';

class PlaceSearchBloc extends Bloc<PlaceSearchEvent, PlaceSearchState>
    with ChangeNotifier {
  final PlacesService _placesService = PlacesService();
  List<PlaceSearch> searchResults = [];

  // * Stream for location search results
  BehaviorSubject<GooglePlace> selectedLocation =
      BehaviorSubject<GooglePlace>();

  void searchPlaces(String searchTerm) async {
    print('Search: $searchTerm');
    searchResults = await _placesService.getAutoComplete(searchTerm);
    print('Search Result 1: ${searchResults.first.description}');

    notifyListeners();
  }

  void searchRegionsAndCities(String searchTerm) async {
    searchResults =
        await _placesService.getAutoCompleteRegionsAndCities(searchTerm);
    notifyListeners();
  }

  void setSelectedLocation(String placeId) async {
    selectedLocation.add(await _placesService.getPlace(placeId));
    notifyListeners();
  }

  PlaceSearchBloc() : super(PlaceSearchState.initial()) {
    on<PlaceSearchEvent>((event, emit) async {
      if (event is PlaceSearchStarted) {
        print('Search Started');

        emit(PlaceSearchState.loading());
      }
      if (event is PlaceSelected) {
        //  emit(PlaceSearchState.loaded(placeDetails.result!));
      }
    });
    on<PlaceSearchbarClicked>(
        (event, emit) => emit(PlaceSearchState.focused()));
    on<PlaceSearchbarClosed>(
        (event, emit) => emit(PlaceSearchState.unfocused()));
  }
}
