import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/bloc/place_search_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_categories_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/category_page.dart';
import 'package:leggo/model/category.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:reorderables/reorderables.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

final router = GoRouter(initialLocation: '/', routes: [
  GoRoute(
      name: '/',
      path: '/',
      pageBuilder: (context, state) => const MaterialPage<void>(
              child: MyHomePage(
            title: 'Leggo',
          )),
      routes: [
        GoRoute(
          path: 'category-page',
          pageBuilder: (context, state) =>
              const MaterialPage<void>(child: CategoryPage()),
        )
      ]),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PlaceSearchBloc(),
        ),
        BlocProvider(
          create: (context) => SavedPlacesBloc(),
        ),
        BlocProvider(
          create: (context) =>
              SavedCategoriesBloc()..add(LoadSavedCategories()),
        ),
      ],
      child: MaterialApp.router(
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.deepBlue,
          useMaterial3: true,
          useMaterial3ErrorColors: true,
        ),
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        routerDelegate: router.routerDelegate,
        title: 'Flutter Demo',
        theme: FlexThemeData.light(
            scheme: FlexScheme.espresso, useMaterial3: true),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<SavedCategoriesBloc, SavedCategoriesState>(
          builder: (context, state) {
            if (state is SavedCategoriesLoading ||
                state is SavedCategoriesUpdated) {
              return Center(
                child: LoadingAnimationWidget.newtonCradle(
                    color: Theme.of(context).primaryColor, size: 120.0),
              );
            }
            if (state is SavedCategoriesFailed) {
              return const Center(
                child: Text('Error Loading Lists!'),
              );
            }
            if (state is SavedCategoriesLoaded) {
              final ScrollController mainScrollController = ScrollController();

              List<Widget> rows = [
                for (Category category in state.categories)
                  CategoryCard(category: category)
              ];

              void _onReorder(int oldIndex, int newIndex) {
                Category category = state.categories.removeAt(oldIndex);
                state.categories.insert(newIndex, category);
                setState(() {
                  Widget row = rows.removeAt(oldIndex);
                  rows.insert(newIndex, row);
                });
              }

              return CustomScrollView(
                controller: mainScrollController,
                slivers: [
                  SliverAppBar.medium(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu),
                      ),
                    ),
                    title: Wrap(
                      spacing: 18.0,
                      children: const [
                        Icon(FontAwesomeIcons.buildingCircleCheck),
                        Text(
                          'GottaGo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    expandedHeight: 120,
                    actions: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.more_vert))
                    ],
                  ),
                  // Main List View

                  ReorderableSliverList(
                      delegate: ReorderableSliverChildBuilderDelegate(
                          childCount: state.categories.isNotEmpty
                              ? state.categories.length
                              : 1, (context, index) {
                        if (state.categories.isNotEmpty) {
                          // rows.clear();
                          rows = [
                            for (Category category in state.categories)
                              CategoryCard(category: category)
                          ];

                          return rows[index];
                        }
                        // if (state.categories.isEmpty) {
                        //   rows.add(const BlankCategoryCard());

                        //   return rows[index];
                        // }
                        else {
                          rows.clear();
                          int sampleCardCount = 5;
                          List<SampleCategoryCard> sampleCategoryCards = [];
                          for (int i = 0; i < sampleCardCount; i++) {
                            sampleCategoryCards.add(const SampleCategoryCard());
                            rows = sampleCategoryCards;
                          }
                          return rows[index];
                        }
                      }),
                      onReorder: _onReorder)
                ],
              );
            } else {
              return const Center(
                child: Text('Something Went Wrong...'),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const CreateListDialog();
              },
            );
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add_circle_outline_rounded),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: FlexColor.deepBlueDarkPrimaryContainer.withOpacity(0.15),
                child: ListTile(
                  onTap: () {
                    context.read<SavedPlacesBloc>().add(LoadPlaces());
                    context.go('/category-page');
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  minLeadingWidth: 20,

                  //tileColor: categoryColor,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10.0,
                      children: [
                        category.icon != null
                            ? Icon(
                                category.icon,
                                size: 18,
                              )
                            : const SizedBox(),
                        Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Text('${category.places?.length ?? 0} Saved Places'),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        right: 20,
                        bottom: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.network(
                              'https://www.google.com/maps/uv?pb=!1s0x89e8287866d3ffff:0xa6734768501a1e3f!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe%3Dw258-h160-k-no!5shatch+huntington+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe&hl=en&sa=X&ved=2ahUKEwiwmoaj84D6AhWWkIkEHfHKDhUQoip6BAhREAM',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Image.network(
                            'https://www.google.com/maps/uv?pb=!1s0x89e82b9897a768f9:0x2853132db2dacf1b!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur%3Dw168-h160-k-no!5sdown+diner+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur&hl=en&sa=X&ved=2ahUKEwjwieGP9ID6AhVslokEHRRnBuIQoip6BAhnEAM',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlankCategoryCard extends StatelessWidget {
  const BlankCategoryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: FlexColor.deepBlueDarkPrimaryContainer.withOpacity(0.6),
                child: ListTile(
                  minVerticalPadding: 30.0,
                  onTap: () {
                    //context.read<SavedPlacesBloc>().add(LoadPlaces());
                    // context.go('/category-page');
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const CreateListDialog();
                      },
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  minLeadingWidth: 20,

                  //tileColor: categoryColor,
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10.0,
                    children: [
                      const Icon(
                        FontAwesomeIcons.list,
                        size: 18,
                      ),
                      Text(
                        'Create a List',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // subtitle: const Padding(
                  //   padding: EdgeInsets.only(left: 24.0),
                  //   child: Text('0 Saved Places'),
                  // ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: SizedBox(
                      child: Stack(clipBehavior: Clip.none, children: [
                        Positioned(
                          right: 20,
                          bottom: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Container(
                                  color:
                                      FlexColor.deepBlueDarkSecondaryVariant),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Container(
                              color: FlexColor.deepBlueDarkTertiaryContainer,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SampleCategoryCard extends StatelessWidget {
  const SampleCategoryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: FlexColor.deepBlueDarkPrimaryContainer,
                child: ListTile(
                  minVerticalPadding: 24.0,
                  onTap: () {
                    //context.read<SavedPlacesBloc>().add(LoadPlaces());
                    // context.go('/category-page');
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const CreateListDialog();
                      },
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  minLeadingWidth: 20,

                  //tileColor: categoryColor,
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10.0,
                    children: [
                      const Icon(
                        FontAwesomeIcons.list,
                        size: 18,
                      ),
                      Text(
                        'Create a List',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // subtitle: const Padding(
                  //   padding: EdgeInsets.only(left: 24.0),
                  //   child: Text('0 Saved Places'),
                  // ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: SizedBox(
                      child: Stack(clipBehavior: Clip.none, children: [
                        Positioned(
                          right: 20,
                          bottom: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Container(
                                  color:
                                      FlexColor.deepBlueDarkSecondaryVariant),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Container(
                              color: FlexColor.deepBlueDarkTertiaryContainer,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateListDialog extends StatelessWidget {
  const CreateListDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController listNameController = TextEditingController();
    return Dialog(
      backgroundColor: FlexColor.deepBlueDarkPrimaryContainer,
      child: SizedBox(
        height: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create New List:',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: listNameController,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: "ex. Breakfast Ideas",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(fixedSize: const Size(150, 35)
                      // backgroundColor: FlexColor.espressoDarkTertiary,
                      ),
                  onPressed: () {
                    print('Category Added: ${listNameController.value.text}');
                    context.read<SavedCategoriesBloc>().add(AddCategory(
                        category: Category(
                            name: listNameController.value.text,
                            contributorIds: ['userId'])));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Create List')),
            )
          ],
        ),
      ),
    );
  }
}
