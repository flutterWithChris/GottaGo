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
import 'package:leggo/bloc/bloc/invite/bloc/invite_bloc.dart';
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
import 'package:leggo/widgets/lists/blank_category_card.dart';
import 'package:leggo/widgets/lists/category_card.dart';
import 'package:leggo/widgets/lists/create_list_dialog.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';
import 'package:leggo/widgets/lists/sample_category_card.dart';
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
          BlocProvider(
            create: (context) => InviteBloc(
                placeListRepository: context.read<PlaceListRepository>()),
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
    final List<PlaceList> samplePlaceLists = [];
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
                      enabled: false,
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
