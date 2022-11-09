part of 'autocomplete_bloc.dart';

abstract class AutocompleteState extends Equatable {
  final List<PlaceSearch>? autoComplete;
  const AutocompleteState({this.autoComplete});

  @override
  List<Object?> get props => [autoComplete];
}

class AutocompleteLoading extends AutocompleteState {}

class AutocompleteLoaded extends AutocompleteState {
  final List<PlaceSearch>? autocomplete;
  const AutocompleteLoaded({
    required this.autocomplete,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [autocomplete];
}

class AutocompleteFailed extends AutocompleteState {}
