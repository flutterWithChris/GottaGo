import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';
import 'package:meta/meta.dart';

part 'place_search_event.dart';
part 'place_search_state.dart';

class PlaceSearchBloc extends Bloc<PlaceSearchEvent, PlaceSearchState> {
  PlaceSearchBloc() : super(PlaceSearchState.initial()) {
    final GooglePlace googlePlace =
        GooglePlace(dotenv.env['GOOGLE_PLACES_API_KEY']!);
    on<PlaceSearchEvent>((event, emit) async {
      if (event is PlaceSearchStarted) {
        List<AutocompletePrediction> predictions = [];
        if (event.searchTerm!.isNotEmpty) {
          var place = await googlePlace.autocomplete.get(event.searchTerm!);
          predictions = place!.predictions!;
          emit(PlaceSearchState.loading(predictions));
        } else {
          emit(PlaceSearchState.initial());
        }
      }
      if (event is PlaceSelected) {
        var placeDetails =
            await googlePlace.details.get(event.suggestion!.placeId!);
        if (placeDetails!.result != null) {
          placeDetails.result!.name;
          emit(PlaceSearchState.loaded(placeDetails.result!));
        } else {
          emit(PlaceSearchState.failed());
        }
      }
    });

    Future<Uint8List?> getPhotos(String photoReference) async {
      var photo = await googlePlace.photos.get(photoReference, 1080, 1920);
      return photo;
    }
  }
}
