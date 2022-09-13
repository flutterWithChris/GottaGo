part of 'saved_categories_bloc.dart';

abstract class SavedCategoriesState extends Equatable {
  List<Category>? categories;
  SavedCategoriesState({this.categories});

  @override
  List<Object> get props => [categories!];
}

class SavedCategoriesLoading extends SavedCategoriesState {}

class SavedCategoriesLoaded extends SavedCategoriesState {
  @override
  final List<Category> categories;
  SavedCategoriesLoaded({required this.categories});
  @override
  // TODO: implement props
  List<Object> get props => [categories];
}

class SavedCategoriesFailed extends SavedCategoriesState {}

class SavedCategoriesUpdated extends SavedCategoriesState {
  Category category;
  SavedCategoriesUpdated({required this.category});
  @override
  // TODO: implement props
  List<Object> get props => [category];
}
