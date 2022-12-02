import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/repository/places_repository.dart';

part 'place_event.dart';
part 'place_state.dart';

class PlaceBloc extends Bloc<PlaceEvent, PlaceState> {
  final PlacesRepository _placesRepository;
  StreamSubscription? _placesSubscription;
  PlaceBloc({required PlacesRepository placesRepository})
      : _placesRepository = placesRepository,
        super(PlaceLoading()) {
    on<LoadPlace>((event, emit) async {
      _placesSubscription?.cancel();

      final GooglePlace googlePlace =
          await _placesRepository.getPlace(event.placeId);

      emit(PlaceLoaded(googlePlace: googlePlace));
    });
  }
  @override
  Future<void> close() {
    // TODO: implement close
    _placesSubscription?.cancel();
    return super.close();
  }
}
