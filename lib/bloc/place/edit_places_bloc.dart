import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/repository/place_list_repository.dart';

part 'edit_places_event.dart';
part 'edit_places_state.dart';

class EditPlacesBloc extends Bloc<EditPlacesEvent, EditPlacesState> {
  final PlaceListRepository _placeListRepository;
  List<Place> selectedPlaces = [];
  EditPlacesBloc({required PlaceListRepository placeListRepository})
      : _placeListRepository = placeListRepository,
        super(EditPlacesInitial()) {
    on<EditPlacesEvent>((event, emit) {
      print('Bloc Placelist Length: ${selectedPlaces.length}');
    });
    on<StartEditing>((event, emit) {
      selectedPlaces.clear();
      emit(EditPlacesStarted());
    });
    on<FinishEditing>((event, emit) {
      emit(EditPlacesLoading());
      emit(EditPlacesSubmitted(
          places: event.places, placeList: event.placeList));
    });
    on<DeletePlaces>((event, emit) async {
      emit(EditPlacesLoading());
      for (Place place in selectedPlaces) {
        await _placeListRepository.removePlaceFromList(place, event.placeList);
      }
      emit(EditPlacesSubmitted(
          places: selectedPlaces, placeList: event.placeList));
      await Future.delayed(const Duration(seconds: 2));
      emit(EditPlacesInitial());
    });
    on<DeleteVisitedPlaces>((event, emit) async {
      emit(EditPlacesLoading());
      for (Place place in selectedPlaces) {
        await _placeListRepository.removePlaceFromVisitedList(
            place, event.placeList);
      }
      emit(EditPlacesSubmitted(
          places: selectedPlaces, placeList: event.placeList));
      await Future.delayed(const Duration(seconds: 2));
      emit(EditPlacesInitial());
    });
    on<DeleteVisitedPlace>((event, emit) async {
      emit(EditPlacesLoading());
      await _placeListRepository.removePlaceFromVisitedList(
          event.place, event.placeList);
      emit(EditPlacesSubmitted(
          places: selectedPlaces, placeList: event.placeList));
      await Future.delayed(const Duration(seconds: 2));
      emit(EditPlacesInitial());
    });
    on<MarkVisitedPlaces>((event, emit) async {
      emit(EditPlacesLoading());
      for (Place place in selectedPlaces) {
        await _placeListRepository.markPlaceVisited(place, event.placeList);
      }
      emit(EditPlacesSubmitted(
          places: selectedPlaces, placeList: event.placeList));
      await Future.delayed(const Duration(seconds: 2));
      emit(EditPlacesInitial());
    });
    on<DeletePlace>((event, emit) async {
      emit(EditPlacesLoading());

      await _placeListRepository.removePlaceFromList(
          event.place, event.placeList);

      emit(EditPlacesSubmitted(
          places: selectedPlaces, placeList: event.placeList));
      await Future.delayed(const Duration(seconds: 2));
      emit(EditPlacesInitial());
    });
    on<MarkVisitedPlace>((event, emit) async {
      emit(EditPlacesLoading());

      await _placeListRepository.markPlaceVisited(event.place, event.placeList);

      emit(EditPlacesSubmitted(
          places: selectedPlaces, placeList: event.placeList));
      await Future.delayed(const Duration(seconds: 2));
      emit(EditPlacesInitial());
    });
    on<UnVisitPlace>((event, emit) async {
      emit(EditPlacesLoading());

      await _placeListRepository.restoreVisitedPlace(
          event.place, event.placeList);

      emit(EditPlacesSubmitted(
          places: selectedPlaces, placeList: event.placeList));
      await Future.delayed(const Duration(seconds: 2));
      emit(EditPlacesInitial());
    });
    on<CancelEditing>((event, emit) {
      emit(EditPlacesInitial());
    });
    on<SelectPlace>((event, emit) {
      print('Place Selected (BLOC)');
      selectedPlaces.add(event.place);
      emit(PlaceAdded(place: event.place));
      emit(EditPlacesStarted());
    });
    on<UnselectPlace>((event, emit) {
      print('Place Unselected (BLOC)');
      selectedPlaces.remove(event.place);
      emit(PlaceRemoved(place: event.place));
      emit(EditPlacesStarted());
    });
  }
}
