import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../model/place.dart';

part 'view_place_state.dart';

class ViewPlaceCubit extends Cubit<ViewPlaceState> {
  ViewPlaceCubit() : super(ViewPlaceInitial());
  void viewPlace(Place place) => _onViewPlace(place);

  void _onViewPlace(Place place) async {
    emit(ViewPlaceLoading());
    // GooglePlace googlePlace = GooglePlace(dotenv.get('GOOGLE_PLACES_API_KEY'));
    // DetailsResponse? googlePlaceDetails =
    //     await googlePlace.details.get(place.googlePlaceId);
    emit(ViewPlaceLoaded(place: place));
  }
}
