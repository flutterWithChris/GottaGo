import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/place_search.dart';
import 'package:leggo/repository/places_repository.dart';

part 'autocomplete_event.dart';
part 'autocomplete_state.dart';

class AutocompleteBloc extends Bloc<AutocompleteEvent, AutocompleteState> {
  final PlacesRepository _placesRepository;
  StreamSubscription? _placesSubscription;
  AutocompleteBloc({required PlacesRepository placesRepository})
      : _placesRepository = placesRepository,
        super(AutocompleteLoading()) {
    on<AutocompleteEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LoadAutocomplete>((event, emit) async {
      _placesSubscription?.cancel();

      List<PlaceSearch> autoComplete =
          await _placesRepository.getAutoComplete(event.searchInput);
      print(
          'Searching: "${event.searchInput}" & Got ${autoComplete.length} results');
      emit(AutocompleteLoaded(autocomplete: autoComplete));
    });
  }
}
