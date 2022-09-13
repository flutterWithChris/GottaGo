import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leggo/model/category.dart';

part 'saved_categories_event.dart';
part 'saved_categories_state.dart';

class SavedCategoriesBloc
    extends Bloc<SavedCategoriesEvent, SavedCategoriesState> {
  SavedCategoriesBloc() : super(SavedCategoriesLoading()) {
    List<Category> savedCategories = [];
    on<SavedCategoriesEvent>((event, emit) async {
      if (event is LoadSavedCategories) {
        await Future.delayed(const Duration(seconds: 2));
        emit(SavedCategoriesLoaded(categories: savedCategories));
      }
      if (event is AddCategory) {
        savedCategories.add(event.category);
        emit(SavedCategoriesUpdated(category: event.category));
        await Future.delayed(const Duration(seconds: 1));
        emit(SavedCategoriesLoaded(categories: savedCategories));
      }
      if (event is UpdateSavedCategories) {
        emit(SavedCategoriesLoaded(categories: savedCategories));
      }
      if (event is RemoveCategory) {
        emit(SavedCategoriesUpdated(category: event.category));
        await Future.delayed(const Duration(seconds: 1));
        add(LoadSavedCategories());
      }
    });
  }
}
