import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'list_sort_state.dart';

class ListSortCubit extends Cubit<ListSortState> {
  ListSortCubit() : super(ListSortInitial());
  void sortByVisitedStatus(String status) {
    emit(ListSortChanged(status: status));
  }
}
