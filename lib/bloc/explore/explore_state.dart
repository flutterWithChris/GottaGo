part of 'explore_bloc.dart';

class ExploreState extends Equatable {
  final GooglePlace? googlePlace;
  final GptPlace? gptPlace;
  final String? placeType;
  final String? city;
  final String? state;
  final String? query;
  const ExploreState(
      {this.googlePlace,
      this.gptPlace,
      this.placeType,
      this.city,
      this.state,
      this.query});

  @override
  List<Object?> get props =>
      [googlePlace, gptPlace, placeType, city, state, query];

  ExploreState copyWith(
      {GooglePlace? googlePlace,
      GptPlace? gptPlace,
      String? placeType,
      String? city,
      String? state,
      String? query}) {
    return ExploreState(
      googlePlace: googlePlace ?? googlePlace,
      gptPlace: gptPlace ?? gptPlace,
      placeType: placeType ?? placeType,
      city: city ?? city,
      state: state ?? state,
      query: query ?? query,
    );
  }
}

class ExploreInitial extends ExploreState {
  @override
  final String? placeType;
  @override
  final String? city;
  @override
  final String? state;

  const ExploreInitial({this.placeType, this.city, this.state});

  @override
  List<Object?> get props => [placeType, city, state];
}

class ExploreLoading extends ExploreState {
  @override
  final String? placeType;
  @override
  final String? city;
  @override
  final String? state;

  const ExploreLoading({this.placeType, this.city, this.state});

  @override
  List<Object?> get props => [placeType, city, state];
}

class ExploreLoaded extends ExploreState {
  @override
  final GooglePlace googlePlace;
  @override
  final GptPlace gptPlace;
  @override
  final String placeType;
  @override
  final String city;
  @override
  final String state;
  @override
  final String query;

  const ExploreLoaded(this.googlePlace, this.gptPlace, this.placeType,
      this.city, this.state, this.query);

  @override
  List<Object> get props =>
      [googlePlace, gptPlace, placeType, city, state, query];
}

class ExploreError extends ExploreState {
  @override
  final String? placeType;
  @override
  final String? city;
  @override
  final String? state;
  final String? message;

  const ExploreError({this.message, this.placeType, this.city, this.state});

  @override
  List<Object?> get props => [message, placeType, city, state];
}
