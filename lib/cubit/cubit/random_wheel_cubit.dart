import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:leggo/model/place.dart';

part 'random_wheel_state.dart';

class RandomWheelCubit extends Cubit<RandomWheelState> {
  final List<Place> places = [];
  Place? selectedPlace;
  RandomWheelCubit() : super(RandomWheelInitial());
  void loadWheel(List<Place> places) => _onLoadWheel(places);
  void spinWheel() => emit(RandomWheelSpun());
  void wheelHasChosen(Place place) => _onWheelHasChosen(place);
  void resetWheel() => emit(RandomWheelInitial());

  void _onLoadWheel(List<Place> places) {
    emit(RandomWheelLoading());
    emit(RandomWheelLoaded(places: places));
  }

  void _onWheelHasChosen(Place place) async {
    selectedPlace = place;
    //   GooglePlace googlePlace = GooglePlace(dotenv.get('GOOGLE_PLACES_API_KEY'));
    //   DetailsResponse? googlePlaceDetails =
    //       await googlePlace.details.get(place.googlePlaceId);
    //   emit(RandomWheelChosen(
    //       selectedPlace: place, googlePlaceDetails: googlePlaceDetails));
    // }
  }
}
