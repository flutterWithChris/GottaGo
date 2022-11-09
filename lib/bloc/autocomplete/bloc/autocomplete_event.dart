part of 'autocomplete_bloc.dart';

abstract class AutocompleteEvent extends Equatable {
  const AutocompleteEvent();

  @override
  List<Object> get props => [];
}

class LoadAutocomplete extends AutocompleteEvent {
  final String searchInput;

  const LoadAutocomplete({this.searchInput = ''});

  @override
  // TODO: implement props
  List<Object> get props => [searchInput];
}
