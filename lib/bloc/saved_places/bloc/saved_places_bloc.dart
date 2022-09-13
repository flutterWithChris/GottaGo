import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/place.dart';

part 'saved_places_event.dart';
part 'saved_places_state.dart';

class SavedPlacesBloc extends Bloc<SavedPlacesEvent, SavedPlacesState> {
  SavedPlacesBloc() : super(SavedPlacesLoading()) {
    final List<Place> savedPlaces = [
      Place(
        closingTime: '3PM',
        name: 'Hatch',
        address: '',
        city: 'Huntington, NY',
        description:
            'An extensive menu of classic & creative American breakfast dishes with contemporary...',
        type: 'Restaurant',
        mainPhoto:
            'https://www.google.com/maps/uv?pb=!1s0x89e8287866d3ffff:0xa6734768501a1e3f!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe%3Dw258-h160-k-no!5shatch+huntington+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe&hl=en&sa=X&ved=2ahUKEwiwmoaj84D6AhWWkIkEHfHKDhUQoip6BAhREAM',
      ),
      // Place(
      //   closingTime: '3PM',
      //   name: 'Whiskey Down Diner',
      //   address: '',
      //   city: 'Farmingdale, NY',
      //   description:
      //       'Familiar all-day diner offering typical comfort food such as pancakes, eggs, burgers...',
      //   type: 'Cafe',
      //   mainPhoto:
      //       'https://www.google.com/maps/uv?pb=!1s0x89e82b9897a768f9%3A0x2853132db2dacf1b!3m1!7e115!4shttps%3A%2F%2Flh5.googleusercontent.com%2Fp%2FAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur%3Dw168-h160-k-no!5sdown%20diner%20-%20Google%20Search!15sCgIgAQ&imagekey=!1e10!2sAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur&hl=en&sa=X&ved=2ahUKEwjAmaKshYH6AhXNjYkEHQs5C6IQoip6BAhpEAM#',
      // ),
      Place(
        closingTime: '3PM',
        name: 'Jardin Cafe',
        city: 'Patchogue, NY',
        address: '',
        description:
            '"I was pleasantly surprised to see such a varied menu with meat and tofu options."',
        type: 'Cafe',
        mainPhoto:
            'https://www.google.com/maps/uv?pb=!1s0x89e849a3c6fe856d:0xabd40cec3dcf19a6!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipPOidJNkMv1UYjBKbw5sXQvANFfLayn9uCamtQH%3Dw120-h160-k-no!5sjardin+cafe+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipPOidJNkMv1UYjBKbw5sXQvANFfLayn9uCamtQH&hl=en&sa=X&ved=2ahUKEwjMg7HPhYH6AhURj4kEHf7oBT8Qoip6BAhdEAM',
      ),
      Place(
        closingTime: '10PM',
        name: 'Rise & Grind',
        address: '',
        city: 'Patchogue, NY',
        type: 'Cafe',
        description: '"excellent food, coffee and service..."',
        mainPhoto:
            'https://www.google.com/maps/uv?pb=!1s0x89c41f115b12a40f%3A0x1cb4aeb28234535!3m1!7e115!4shttps%3A%2F%2Flh5.googleusercontent.com%2Fp%2FAF1QipPxetTYWtNtyheHagncbjDIbW59m9kKW9pYS9Mk%3Dw120-h160-k-no!5srise%20and%20grind%20cafe%20-%20Google%20Search!15sCgIgAQ&imagekey=!1e10!2sAF1QipPxetTYWtNtyheHagncbjDIbW59m9kKW9pYS9Mk&hl=en&sa=X&ved=2ahUKEwjc4_a6hoH6AhWclIkEHbtlBrMQoip6BAhpEAM# ',
      ),
    ];

    on<SavedPlacesEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is LoadPlaces) {
        await Future.delayed(const Duration(seconds: 2));
        emit(SavedPlacesLoaded(places: savedPlaces));
      }
      if (event is AddPlace) {
        emit(SavedPlacesLoading());
        savedPlaces.insert(0, event.place);
        emit(SavedPlacesUpdated(places: savedPlaces));
        emit(SavedPlacesLoaded(places: savedPlaces));
      }
      if (event is RemovePlace) {
        emit(SavedPlacesLoading());
        await Future.delayed(
            const Duration(seconds: 1), () => savedPlaces.remove(event.place));
        emit(SavedPlacesUpdated(places: savedPlaces));
        emit(SavedPlacesLoaded(places: savedPlaces));
      }
      if (event is UpdatePlace) {
        emit(SavedPlacesUpdated(places: savedPlaces));
        emit(SavedPlacesLoaded(places: savedPlaces));
      }
    });
  }
}
