import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leggo/bloc/bloc/auth/bloc/auth_bloc.dart';
import 'package:leggo/bloc/bloc/place_search_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/category_page.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';
import 'package:leggo/firebase_options.dart';
import 'package:leggo/login.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/random_wheel_page.dart';
import 'package:leggo/repository/auth_repository.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/repository/user_repository.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:reorderables/reorderables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    dotenv.load(fileName: '.env'),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthBloc bloc;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider(
          create: (context) => PlaceListRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
                userRepository: context.read<UserRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                LoginCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => PlaceSearchBloc(),
          ),
          BlocProvider(
            create: (context) => SavedPlacesBloc(
                placeListRepository: context.read<PlaceListRepository>()),
          ),
          BlocProvider(
            create: (context) => SavedListsBloc(
                placeListRepository: context.read<PlaceListRepository>())
              ..add(LoadSavedLists()),
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            bloc = context.read<AuthBloc>();
            return MaterialApp.router(
              theme: FlexThemeData.light(
                scheme: FlexScheme.deepBlue,
                surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
                blendLevel: 20,
                appBarOpacity: 0.95,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 20,
                  blendOnColors: false,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
                fontFamily: GoogleFonts.lato().fontFamily,
                // To use the playground font, add GoogleFonts package and uncomment
                // fontFamily: GoogleFonts.notoSans().fontFamily,
              ),
              darkTheme: FlexThemeData.dark(
                scheme: FlexScheme.deepBlue,
                surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
                blendLevel: 15,
                appBarOpacity: 0.90,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 30,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
                // To use the playground font, add GoogleFonts package and uncomment
                fontFamily: GoogleFonts.lato().fontFamily,
              ),
              // If you do not have a themeMode switch, uncomment this line
              // to let the device system mode control the theme mode:
              themeMode: ThemeMode.system,
              routeInformationParser: router.routeInformationParser,
              routeInformationProvider: router.routeInformationProvider,
              routerDelegate: router.routerDelegate,
              title: 'Flutter Demo',
            );
          },
        ),
      ),
    );
  }

  late final router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(bloc.stream),
      redirect: (state) {
        bool loggedIn = bloc.state.status == AuthStatus.authenticated;
        // bool loggedIn = true;
        bool isLoggingIn = state.location == '/login';
        bool completedOnboarding = true;
        bool isOnboarding = state.location == '/signup';

        if (!loggedIn) {
          return isLoggingIn
              ? null
              : isOnboarding
                  ? null
                  : '/login';
        }

        final isLoggedIn = state.location == '/';

        if (loggedIn && completedOnboarding == false) return null;
        if (loggedIn && isLoggingIn) return isLoggedIn ? null : '/';
        if (loggedIn && isOnboarding) return isLoggedIn ? null : '/';

        return null;
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              const MaterialPage<void>(child: LoginPage()),
        ),
        GoRoute(
            name: '/',
            path: '/',
            pageBuilder: (context, state) => const MaterialPage<void>(
                    child: MyHomePage(
                  title: 'Leggo',
                )),
            routes: [
              GoRoute(
                  path: 'home/placeList-page',
                  pageBuilder: (context, state) =>
                      const MaterialPage<void>(child: CategoryPage()),
                  routes: [
                    GoRoute(
                      name: 'random-wheel',
                      path: 'home/placeList-page/random-wheel',
                      pageBuilder: (context, state) =>
                          const MaterialPage<void>(child: RandomWheelPage()),
                    )
                  ])
            ]),
      ]);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> rows = [];
  @override
  Widget build(BuildContext context) {
    final List<PlaceList> samplePlaceLists = [
      PlaceList(
          name: 'Breakfast Ideas', icon: Icons.egg, contributorIds: ['userId']),
      PlaceList(
          name: 'Lunch Spots',
          icon: FontAwesomeIcons.bowlFood,
          contributorIds: ['userId']),
      PlaceList(
          name: 'Dinner',
          icon: FontAwesomeIcons.utensils,
          contributorIds: ['userId']),
      PlaceList(
          name: 'Iceland Trip',
          icon: FontAwesomeIcons.earthOceania,
          contributorIds: ['userId']),
      PlaceList(
          name: 'Travel',
          icon: FontAwesomeIcons.earthAmericas,
          contributorIds: ['userId']),
    ];
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: const MainBottomNavBar(),
        body: BlocBuilder<SavedListsBloc, SavedListsState>(
          builder: (context, state) {
            if (state is SavedListsLoading || state is SavedListsUpdated) {
              return Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: FlexColor.materialDarkPrimaryHc, size: 40.0),
              );
            }
            if (state is SavedListsFailed) {
              return const Center(
                child: Text('Error Loading Lists!'),
              );
            }
            if (state is SavedListsLoaded) {
              final ScrollController mainScrollController = ScrollController();

              void addCategoriesToList() {
                for (PlaceList placeList in state.placeLists) {
                  rows.add(CategoryCard(placeList: placeList));
                }
              }

              if (state.placeLists.isNotEmpty) {
                addCategoriesToList();
              }

              void _onReorder(int oldIndex, int newIndex) {
                PlaceList placeList = state.placeLists.removeAt(oldIndex);
                state.placeLists.insert(newIndex, placeList);
                setState(() {
                  Widget row = rows.removeAt(oldIndex);
                  rows.insert(newIndex, row);
                });
              }

              void _onReorderSampleItem(int oldIndex, int newIndex) {
                PlaceList placeList = samplePlaceLists.removeAt(oldIndex);
                samplePlaceLists.insert(newIndex, placeList);
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
                          onPressed: () {}, icon: const Icon(Icons.more_vert)),
                      IconButton(
                          onPressed: () {
                            context.read<LoginCubit>().logout();
                          },
                          icon: const Icon(Icons.logout_rounded)),
                    ],
                  ),
                  // Main List View
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 12.0),
                  ),
                  ReorderableSliverList(
                      delegate: ReorderableSliverChildBuilderDelegate(
                          childCount: state.placeLists.isNotEmpty
                              ? state.placeLists.length
                              : 6, (context, index) {
                        if (state.placeLists.isNotEmpty) {
                          // rows.clear();
                          rows = [
                            for (PlaceList placeList in state.placeLists)
                              Animate(
                                  effects: const [SlideEffect()],
                                  child: CategoryCard(placeList: placeList))
                          ];

                          return rows[index];
                        } else {
                          rows.clear();
                          List<SampleCategoryCard> sampleCategoryCards = [];
                          for (PlaceList placeList in samplePlaceLists) {
                            rows.add(Animate(
                                effects: const [SlideEffect()],
                                child:
                                    SampleCategoryCard(placeList: placeList)));
                          }
                          rows.insert(
                              0,
                              Animate(
                                  effects: const [SlideEffect()],
                                  child: const BlankCategoryCard()));
                          return rows[index];
                        }
                      }),
                      onReorder: _onReorderSampleItem)
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
          shape: const StadiumBorder(),
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
  final PlaceList placeList;

  const CategoryCard({
    Key? key,
    required this.placeList,
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
                //color: FlexColor.deepBlueDarkPrimaryContainer.withOpacity(0.15),
                child: ListTile(
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PopupMenuButton(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        // onSelected: (value) {},
                        icon: const Icon(Icons.more_vert_rounded),
                        itemBuilder: (context) => <PopupMenuEntry>[
                              PopupMenuItem(
                                  onTap: () {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((timeStamp) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const DeleteListDialog();
                                        },
                                      );
                                    });
                                  },
                                  child: const Text('Delete List'))
                            ]),
                  ),
                  onTap: () {
                    context
                        .read<SavedPlacesBloc>()
                        .add(LoadPlaces(placeList: placeList));
                    context.go('/home/placeList-page');
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  minLeadingWidth: 20,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10.0,
                      children: [
                        placeList.icon != null
                            ? Icon(
                                placeList.icon,
                                size: 18,
                              )
                            : const SizedBox(),
                        Text(
                          placeList.name,
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
                    child: Text('${placeList.placeCount} Saved Places'),
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
                            child: CachedNetworkImage(
                              imageUrl:
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
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://www.google.com/maps/uv?pb=!1s0x89e82b9897a768f9:0x2853132db2dacf1b!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur%3Dw168-h160-k-no!5sdown+diner+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur&hl=en&sa=X&ved=2ahUKEwjwieGP9ID6AhVslokEHRRnBuIQoip6BAhnEAM',
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return LoadingAnimationWidget.discreteCircle(
                                  color: Theme.of(context).primaryColor,
                                  size: 18.0);
                            },
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

class DeleteListDialog extends StatefulWidget {
  const DeleteListDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<DeleteListDialog> createState() => _DeleteListDialogState();
}

class _DeleteListDialogState extends State<DeleteListDialog> {
  bool buttonEnabled = false;
  final TextEditingController deleteConfirmFieldController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 250,
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Delete List?',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 270,
              height: 60,
              child: TextField(
                onChanged: (value) {
                  if (value == 'Breakfast Ideas') {
                    setState(() {
                      buttonEnabled = true;
                    });
                  }
                },
                controller: deleteConfirmFieldController,
                autofocus: true,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).highlightColor,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(24.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(20.0)),
                    //  prefixIcon: const Icon(Icons.lock),
                    hintText: "Type 'Breakfast Ideas'"),
              ),
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: buttonEnabled
                    ? () {
                        if (deleteConfirmFieldController.text.isNotEmpty) {
                          context.read<SavedListsBloc>().add(RemoveList(
                              placeList: PlaceList(
                                  name: deleteConfirmFieldController.text)));
                          Navigator.pop(context);
                        }
                      }
                    : null,
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete Forever')),
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
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 4.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 1.618,
                //color: FlexColor.materialDarkPrimaryContainerHc,
                child: ListTile(
                  minVerticalPadding: 30.0,
                  onTap: () {
                    //context.read<SavedPlacesBloc>().add(LoadPlaces());
                    // context.go('/placeList-page');
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
                                  color: FlexColor
                                      .materialDarkTertiaryContainerHc),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Container(
                                color: FlexColor.materialDarkSecondaryHc),
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
  final PlaceList placeList;
  const SampleCategoryCard({
    Key? key,
    required this.placeList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: 0.6,
                child: Card(
                  elevation: 2.0,
                  //  color: FlexColor.deepBlueDarkSecondaryContainer,
                  child: ListTile(
                    minVerticalPadding: 24.0,
                    onTap: () {
                      //context.read<SavedPlacesBloc>().add(LoadPlaces());
                      // context.go('/placeList-page');
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
                        placeList.icon != null
                            ? Icon(
                                placeList.icon,
                                size: 16,
                              )
                            : const SizedBox(),
                        Text(
                          placeList.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Text('12 Saved Places'),
                    ),
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
                                color: FlexColor.deepBlueDarkPrimaryContainer,
                              ),
                            ),
                          ),
                        ]),
                      ),
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
      //backgroundColor: FlexColor.,
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
                    filled: true,
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
                    print('PlaceList Added: ${listNameController.value.text}');
                    context.read<SavedListsBloc>().add(AddList(
                        placeList: PlaceList(
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
