import 'package:bloc/bloc.dart';
import 'package:google_place/google_place.dart';
import 'package:meta/meta.dart';

part 'place_search_event.dart';
part 'place_search_state.dart';

class PlaceSearchBloc extends Bloc<PlaceSearchEvent, PlaceSearchState> {
  PlaceSearchBloc() : super(PlaceSearchState.initial()) {
    on<PlaceSearchEvent>((event, emit) {
      if (event is PlaceSearch) {
        emit(PlaceSearchState.loading());
      }
      if (event is PlaceSelected) {
        emit(PlaceSearchState.loaded(event.detailsResult));
      }
    });
  }
}
