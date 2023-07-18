import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/gpt_place.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/place_search.dart';
import 'package:leggo/repository/chat_gpt/chat_gpt_repository.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/repository/places_repository.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ChatGPTRepository _chatGPTRepository;
  final PlacesRepository _placesRepository;
  final PlaceListRepository _placeListRepository;
  String searchQuery = '';
  String location = '';
  List<String> negativeQueries = [];
  List<String> positiveQueries = [];
  List<String> queryHistory = [];

  ExploreBloc({
    required ChatGPTRepository chatGPTRepository,
    required PlacesRepository placesRepository,
  })  : _chatGPTRepository = chatGPTRepository,
        _placesRepository = placesRepository,
        _placeListRepository = PlaceListRepository(),
        super(const ExploreInitial()) {
    on<LoadExplore>((event, emit) async {
      try {
        emit(const ExploreLoading());

        if (event.negativeQuery != null &&
            negativeQueries.contains(event.negativeQuery!) == false &&
            positiveQueries.contains(event.negativeQuery!) == false) {
          negativeQueries.add(event.negativeQuery!);
        }
        if (event.positiveQuery != null &&
            positiveQueries.contains(event.query!) == false &&
            negativeQueries.contains(event.query!) == false) {
          positiveQueries.add(event.positiveQuery!);
        }
        print('Positive Queries: ${positiveQueries.join(', ')}');
        print('Negative Queries: ${negativeQueries.join(', ')}');
        final GptPlace? gptPlace = await _chatGPTRepository.chatComplete([
          createExploreChatGPTQuery(event.placeType, event.city!, event.state!)
        ], 'User');
        if (gptPlace != null) {
          List<PlaceSearch> results = await _placesRepository.getAutoComplete(
              '${gptPlace.name}, ${gptPlace.city}, ${gptPlace.state}');
          GooglePlace googlePlace =
              await _placesRepository.getPlace(results[0].placeId!);
          queryHistory.add(gptPlace.name);
          print('Query History: ${queryHistory.join(', ')}');
          emit(ExploreLoaded(googlePlace, gptPlace, event.placeType,
              event.city!, event.state!, searchQuery));
        } else {
          emit(const ExploreError(message: 'No response'));
        }
      } catch (e) {
        emit(const ExploreError(message: 'No response'));
        snackbarKey.currentState!.showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text('Error Exploring...')));
      }
    });
    on<SetLocation>(((event, emit) {
      location = '${event.city}, ${event.state}';
    }));
    on<SetQuery>((event, emit) {
      searchQuery = event.query;
    });
    on<AddPlaceToList>((event, emit) async {
      try {
        final PlaceList placeList = event.placeList;
        final Place place = event.place;
        await _placeListRepository.addPlaceToList(place, placeList);
        snackbarKey.currentState!.showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            content: Text('Place Added to List!')));
      } catch (e) {
        emit(const ExploreError(message: 'No response'));
        snackbarKey.currentState!.showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Text('Error Adding Place to List...')));
      }
    });
  }
  String createExploreChatGPTQuery(
    String placeType,
    String city,
    String state,
  ) {
    String basePrompt =
        'Give me 1 place to visit within 1 hour of $city, $state that matches this type: $placeType. Ensure it\'s well-reviewed. Return in JSON format with: name, type, description, city, state. Set the value to null if no data is available.';
    // if (queryHistory.isNotEmpty) {
    //   basePrompt += ' Exclude these places: ';
    //   for (int i = 0; i < queryHistory.length; i++) {
    //     basePrompt += queryHistory[i];
    //     if (i != queryHistory.length - 1) {
    //       basePrompt += ', ';
    //     }
    //   }
    // }

    if (negativeQueries.isNotEmpty) {
      basePrompt += ' Exclude these places & places like it: ';
      for (int i = 0; i < negativeQueries.length; i++) {
        basePrompt += negativeQueries[i];
        if (i != negativeQueries.length - 1) {
          basePrompt += ', ';
        }
      }
      basePrompt += '. ';
    }
    if (positiveQueries.isNotEmpty) {
      basePrompt +=
          ' Prioritize places similar to these suggestions, Exclude the suggestions themselves: ';
      for (int i = 0; i < positiveQueries.length; i++) {
        basePrompt += positiveQueries[i];
        if (i != positiveQueries.length - 1) {
          basePrompt += ', ';
        }
      }
      basePrompt += '. ';
    }
    print('Running Prompt: $basePrompt');
    return basePrompt;
  }
}
