part of 'list_sort_cubit.dart';

abstract class ListSortState extends Equatable {
  final String? status;
  const ListSortState({this.status});

  @override
  List<Object?> get props => [status];
}

class ListSortInitial extends ListSortState {
  @override
  String status = 'Not Visited';
  @override
  // TODO: implement props
  List<Object?> get props => [status];
}

class ListSortChanged extends ListSortState {
  @override
  final String? status;
  const ListSortChanged({
    this.status,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [status];
}
