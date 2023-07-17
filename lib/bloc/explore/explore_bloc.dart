import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/gpt_place.dart';
import 'package:leggo/model/place_search.dart';
import 'package:leggo/repository/chat_gpt/chat_gpt_repository.dart';
import 'package:leggo/repository/places_repository.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ChatGPTRepository _chatGPTRepository;
  final PlacesRepository _placesRepository;
  String? searchQuery;
  String? location;
  ExploreBloc({
    required ChatGPTRepository chatGPTRepository,
    required PlacesRepository placesRepository,
  })  : _chatGPTRepository = chatGPTRepository,
        _placesRepository = placesRepository,
        super(const ExploreInitial()) {
    on<LoadExplore>((event, emit) async {
      emit(const ExploreLoading());
      final GptPlace? gptPlace = await _chatGPTRepository.chatComplete([
        createExploreChatGPTQuery(event.placeType, event.city!, event.state!)
      ], 'User');
      if (gptPlace != null) {
        List<PlaceSearch> results = await _placesRepository.getAutoComplete(
            '${gptPlace.name}, ${gptPlace.city}, ${gptPlace.state}');
        GooglePlace googlePlace =
            await _placesRepository.getPlace(results[0].placeId!);
        emit(ExploreLoaded(
            googlePlace, gptPlace, event.placeType, event.city!, event.state!));
      } else {
        emit(const ExploreError(message: 'No response'));
      }
    });
    on<SetLocation>(((event, emit) {}));
    on<SetQuery>((event, emit) {
      // emit(state.copyWith(query: event.query));
    });
  }
}

String createExploreChatGPTQuery(String placeType, String city, String state) {
  return 'Give me 1 place to visit near $city, $state that matches this type: $placeType. Ensure it\'s well-reviewed. Return in JSON format with: name, type, description, city, state. Set the value to null if no data is available';
}
